package com.reverdir.tomanito.result;

import lombok.Getter;

@Getter
public enum CharacterType {
    ROBOT("하트 충전 중인 깡통 로보트", "/images/robot.png"),
    DOG("꼬리 모터 단 다정 가나지", "/images/dog.png"),
    CAT("박스에 숨은 틱틱 고냐니",  "/images/cat.png"),
    BEAR("겨울잠 깬 부들부들 곰돌이",  "/images/bear.png"),
    MOUSE("도토리 줍는 부지런한 쥐돌이", "/images/mouse.png"),;

    private final String name;
    private final String imageUrl;

    CharacterType(String name, String imageUrl) {
        this.name = name;
        this.imageUrl = imageUrl;
    }
}
