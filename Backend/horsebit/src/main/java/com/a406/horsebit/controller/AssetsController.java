package com.a406.horsebit.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.a406.horsebit.dto.AssetsDTO;
import com.a406.horsebit.dto.HorseTokenDTO;
import com.a406.horsebit.dto.UserTradeDTO;
import com.a406.horsebit.service.AssetsService;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/api/assets")
public class AssetsController {
	private final AssetsService assetsService;

	@Autowired
	public AssetsController(AssetsService assetsService) {
		this.assetsService = assetsService;
	}

	//TODO: OAuth 적용 후 userNo 삭제 필요

	/**
	 * 개인자산 전체조회
	 * @return
	 */
	@GetMapping("")
	public AssetsDTO getUserAssets() {
		Long userNo = 1L;

		return assetsService.findAssetsByUserNo(userNo);
	}

	//TODO:O OAuth 적용 후 userNo 삭제 필요
	/**
	 * 개인자산 토큰 전체조회
	 * @return
	 */
	@GetMapping("/horses")
	public List<HorseTokenDTO> getUserTokens() {
		Long userNo = 1L;

		return assetsService.findTokensByUserNo(userNo);
	}

	//TODO: OAuth 적용 후 userNo 삭제 필요

	/**
	 * 개인 입출금 및 거래내역 전체조회
	 * @return
	 */
	@GetMapping("/investments")
	public List<UserTradeDTO> getUserTrade() {
		Long userNo = 1L;
		log.info("AssetsController::getUserTrade() START");

		return assetsService.findTradeHistoryByUserNo(userNo);
	}
}
