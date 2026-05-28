package com.reverdir.tomanito;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@EnableJpaAuditing
@SpringBootApplication
public class ToManitoApplication {
    public static void main(String[] args) {
        SpringApplication.run(ToManitoApplication.class, args);
    }
}
