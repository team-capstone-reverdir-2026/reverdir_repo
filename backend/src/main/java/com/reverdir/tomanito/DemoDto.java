package com.reverdir.tomanito;

public class DemoDto{
    public record DemoRequest(String content) {}
    public record DemoResponse(String persona, String story) {}
}