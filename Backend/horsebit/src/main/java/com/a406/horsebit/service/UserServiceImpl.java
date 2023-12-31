package com.a406.horsebit.service;

import com.a406.horsebit.config.jwt.TokenProvider;
import com.a406.horsebit.domain.Possess;
import com.a406.horsebit.domain.User;
import com.a406.horsebit.dto.UserSettingDTO;
import com.a406.horsebit.google.domain.Role;
import com.a406.horsebit.google.dto.request.*;
import com.a406.horsebit.google.dto.response.RefreshResponseDTO;
import com.a406.horsebit.google.dto.response.SignInResponseDTO;
import com.a406.horsebit.google.exception.NoSuchUserException;
import com.a406.horsebit.google.repository.InMemoryProviderRepository;
import com.a406.horsebit.repository.TokenRepository;
import com.a406.horsebit.repository.UserRepository;
import com.a406.horsebit.repository.redis.OrderRepository;
import com.nimbusds.jose.JOSEException;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.SignedJWT;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@Transactional
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;
    private final TokenProvider tokenProvider;
    private final InMemoryProviderRepository inMemoryProviderRepository;
    private final AssetsService assetsService;
    private final OrderRepository orderRepository;
    private final TokenRepository tokenRepository;

    public User findById(Long userId){
        return userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Unexpected user"));
    }

    public User findByEmail(String email){
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Unexpected user"));
    }

    @Override
    public SignInResponseDTO signIn(SignInDTO signInDto) throws ParseException, JOSEException {
        log.info("로그인");
        String idToken =signInDto.getToken();
        log.info("토큰입니다." + idToken);
        SignedJWT signedJWT = (SignedJWT) tokenProvider.parseTokenWithoutValidation(idToken);

        try {
            tokenProvider.validateJwtWithJwk(idToken);
        } catch (Exception e) {
            log.info("Id Token 검증 실패: {}", e.getMessage());
            throw new IllegalArgumentException("Id Token이 유효하지 않습니다.");
        }

        // 사용자 조회
        String email = tokenProvider.extractEmail(idToken);
        log.info("이메일 : " + email);
        User user = userRepository.findByEmail(email).orElseThrow(() -> new NoSuchUserException("회원 가입을 먼저 진행하십시오."));
        String accessToken = tokenProvider.bulidAccessToken(user);
        String refreshToken = tokenProvider.buildRefreshToken(user);

        user.setRefreshToken(refreshToken);
        user.setUserName(user.getUserName());

        return SignInResponseDTO.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .userDTO(UserDTO.from(user))
                .build();
    }

    @Override
    public User signUp(SignUpDTO signUpDTO) throws ParseException, JOSEException {
        log.info("회원가입 중");
        String idToken = signUpDTO.getToken();

        SignedJWT signedJWT = (SignedJWT) tokenProvider.parseTokenWithoutValidation(idToken);

        try {
            tokenProvider.validateJwtWithJwk(idToken);
        } catch (Exception e) {
            throw new IllegalArgumentException("Id Token이 유효하지 않습니다. " + e.getMessage());
        }

        String email = tokenProvider.extractEmail(idToken);
        log.info("이메일 : " + email);
        String nickname = tokenProvider.extractNickname(idToken);
        log.info("닉네임 : "+nickname);
        User user = User.builder()
                .email(email)
                .nickname(nickname)
                .userName(signUpDTO.getUserName())
                .build();
//                .bankAccount(signUpDTO.getBankAccount())    //TODO: 계좌 추가

        user.setRole(Role.USER);
        userRepository.save(user);
        Long userId = user.getId();
        log.info("1차 회원정보 입력 완료, userId : "+userId);

        //assets 처음 KRW = 0으로 설정
        Possess possess = assetsService.saveNewAsset(userId, 0L);
        log.info("saveNewAsset 완료 : "+ possess.getShareNo());
        //전체 코인 리스트 담아넣을 수 있게
        List<Long> tokenNoList = new ArrayList<>();
        tokenNoList = tokenRepository.findAllTokenNos();
        orderRepository.newUserOrderList(userId, tokenNoList);

        log.info("회원가입 완료");
        return user;
    }
    
    @Override
    public RefreshResponseDTO issueAccessTokenByRefreshToken(RefreshDTO refreshDTO) {
        log.info("Refresh Token 검증");
        try {
            SignedJWT signedJWT = (SignedJWT) tokenProvider.parseRefreshToken(refreshDTO.getRefreshToken());
            JWTClaimsSet claims = signedJWT.getJWTClaimsSet();
            User user = userRepository.findByEmail(claims.getStringClaim("email")).orElseThrow(() -> new IllegalArgumentException("해당 사용자가 존재하지 않습니다."));

            if (!user.getRefreshToken().equals(refreshDTO.getRefreshToken())) {
                throw new IllegalArgumentException("유효하지 않은 Refresh Token 입니다.");
            }

            String refreshToken = tokenProvider.buildRefreshToken(user);
            user.setRefreshToken(refreshToken);

            String accessToken = tokenProvider.bulidAccessToken(user);

            return RefreshResponseDTO.builder()
                    .accessToken(accessToken)
                    .refreshToken(refreshToken)
                    .build();
        } catch (ParseException | JOSEException e) {
            throw new IllegalArgumentException("유효하지 않은 Refresh Token 입니다. " + e.getMessage());
        }
    }

    //userName 중복확인
    @Override
    public boolean isDuplicatedUserName(String userName) {
        return userRepository.existsByUserName(userName);
    }

    //회원탈퇴
    @Override
    public void deleteUser(Long userId){
        userRepository.deleteById(userId);
    }

    //헤더에 담긴 액세스 토큰에서 유저 정보 조회
    @Override
    public User userInfoFromToken(String accessToken) throws ParseException {
        SignedJWT signedJWT = (SignedJWT) tokenProvider.parseAccessToken(accessToken);
        String email = signedJWT.getJWTClaimsSet().getStringClaim("email");
        log.info("사용자 이메일 : "+email);
        User user = userRepository.findByEmail(email).orElseThrow(() -> new IllegalArgumentException("토큰에 맞는 사용자정보가 없습니다."));

        return user;
    }

    @Override
    public UserSettingDTO findSettingsByUserNo(Long userNo) {
        log.info("UserServiceImpl::findSettingsByUserNo() START");
        User user = userRepository.findById(userNo)
            .orElseThrow(() -> new IllegalArgumentException("Unexpected user"));

        log.info("userSetting: " + user.isAlarmPushFlag() + ", " + user.isBiometricLoginFlag());
        return new UserSettingDTO(user.isAlarmPushFlag(), user.isBiometricLoginFlag());
    }

    @Override
    public void updateSetting(Long userNo, UserSettingDTO userSetting) {
        userRepository.updateSettingByUserNo(userNo, userSetting.isAlarmOn(), userSetting.isBiometricLogin());
    }
}
