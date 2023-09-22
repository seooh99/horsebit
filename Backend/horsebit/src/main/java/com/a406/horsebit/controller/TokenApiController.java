package com.a406.horsebit.controller;

import com.a406.horsebit.dto.reponse.CreateAccessTokenResponse;
import com.a406.horsebit.dto.request.CreateAccessTokenRequest;
import com.a406.horsebit.service.reTokenService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RequiredArgsConstructor
@RestController
public class TokenApiController {
    private final reTokenService reTokenService;

    @PostMapping("/api/token")
    public ResponseEntity<CreateAccessTokenResponse> createNewAccessToken(@RequestBody CreateAccessTokenRequest request){
        String newAccessToken = reTokenService.createNewAccessToken(request.getRefreshToken());

        log.info("AccessToken : " + newAccessToken);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(new CreateAccessTokenResponse(newAccessToken));
    }
}