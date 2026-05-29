package com.reverdir.tomanito.global;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController("/v1/ping")
public class PingController {
    @GetMapping
    public ResponseEntity<Void> ping() {
        return ResponseEntity.ok().build();
    }
}
