package com.a406.horsebit.service;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class InitiatorServiceImplTest {
    private final InitiatorService initiatorService;

    @Autowired
    InitiatorServiceImplTest(InitiatorService initiatorService) {

        this.initiatorService = initiatorService;
    }

    @Test
    void reset() {
        initiatorService.resetOrder();
        for(long tokenNo = 1; tokenNo <= 25; ++tokenNo) {
            initiatorService.resetPrice(tokenNo);
            initiatorService.resetTokens(tokenNo);
            for(long userNo = 1; userNo <= 45; ++userNo) {
                initiatorService.resetUser(userNo, tokenNo);
            }
        }
    }

}