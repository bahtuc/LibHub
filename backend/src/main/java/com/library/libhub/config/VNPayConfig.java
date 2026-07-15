package com.library.libhub.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

/**
 * VNPay merchant settings, bound from the {@code vnpay.*} properties.
 */
@Configuration
@ConfigurationProperties(prefix = "vnpay")
public class VNPayConfig {

    private String tmnCode;
    private String hashSecret;
    private String payUrl;
    private String apiVersion = "2.1.0";
    private String returnUrl;
    private String frontendResultUrl;

    public String getTmnCode() {
        return tmnCode;
    }

    public void setTmnCode(String tmnCode) {
        this.tmnCode = tmnCode;
    }

    public String getHashSecret() {
        return hashSecret;
    }

    public void setHashSecret(String hashSecret) {
        this.hashSecret = hashSecret;
    }

    public String getPayUrl() {
        return payUrl;
    }

    public void setPayUrl(String payUrl) {
        this.payUrl = payUrl;
    }

    public String getApiVersion() {
        return apiVersion;
    }

    public void setApiVersion(String apiVersion) {
        this.apiVersion = apiVersion;
    }

    public String getReturnUrl() {
        return returnUrl;
    }

    public void setReturnUrl(String returnUrl) {
        this.returnUrl = returnUrl;
    }

    public String getFrontendResultUrl() {
        return frontendResultUrl;
    }

    public void setFrontendResultUrl(String frontendResultUrl) {
        this.frontendResultUrl = frontendResultUrl;
    }
}
