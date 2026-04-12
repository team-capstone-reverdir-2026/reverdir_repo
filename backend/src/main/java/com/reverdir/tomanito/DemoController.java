package com.reverdir.tomanito;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/demo")
@CrossOrigin(origins = "*")
public class DemoController {

    private final DemoService demoAiService;

    @PostMapping("/analyze")
    public DemoDto.DemoResponse analyzeNote(@RequestBody DemoDto.DemoRequest request) {
        return demoAiService.analyzeNote(request.content());
    }
}