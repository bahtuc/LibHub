package com.library.libhub.DTO.Response;

public class LoginStartResponse {
    private boolean requiresTwoFactor;
    private String challengeId;
    private String maskedEmail;
    private long expiresInSeconds;
    private AuthResponse user;

    public static LoginStartResponse direct(AuthResponse user) {
        LoginStartResponse response = new LoginStartResponse();
        response.setRequiresTwoFactor(false);
        response.setUser(user);
        return response;
    }

    public boolean isRequiresTwoFactor() {
        return requiresTwoFactor;
    }

    public void setRequiresTwoFactor(boolean requiresTwoFactor) {
        this.requiresTwoFactor = requiresTwoFactor;
    }

    public String getChallengeId() {
        return challengeId;
    }

    public void setChallengeId(String challengeId) {
        this.challengeId = challengeId;
    }

    public String getMaskedEmail() {
        return maskedEmail;
    }

    public void setMaskedEmail(String maskedEmail) {
        this.maskedEmail = maskedEmail;
    }

    public long getExpiresInSeconds() {
        return expiresInSeconds;
    }

    public void setExpiresInSeconds(long expiresInSeconds) {
        this.expiresInSeconds = expiresInSeconds;
    }

    public AuthResponse getUser() {
        return user;
    }

    public void setUser(AuthResponse user) {
        this.user = user;
    }
}
