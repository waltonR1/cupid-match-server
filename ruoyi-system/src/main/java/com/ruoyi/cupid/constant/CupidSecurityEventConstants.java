package com.ruoyi.cupid.constant;

public final class CupidSecurityEventConstants
{
    public static final String EVENT_LOGIN_SUCCESS = "login_success";
    public static final String EVENT_LOGIN_FAILED = "login_failed";
    public static final String EVENT_PASSWORD_CHANGED = "password_changed";
    public static final String EVENT_PASSWORD_RESET = "password_reset";
    public static final String EVENT_IDENTITY_BOUND = "identity_bound";
    public static final String EVENT_IDENTITY_UNBOUND = "identity_unbound";
    public static final String EVENT_SESSION_KICKED = "session_kicked";
    public static final String EVENT_RISK_DETECTED = "risk_detected";

    public static final String RESULT_SUCCESS = "success";
    public static final String RESULT_FAILED = "failed";
    public static final String RESULT_BLOCKED = "blocked";
    public static final String RESULT_DETECTED = "detected";

    private CupidSecurityEventConstants()
    {
    }
}
