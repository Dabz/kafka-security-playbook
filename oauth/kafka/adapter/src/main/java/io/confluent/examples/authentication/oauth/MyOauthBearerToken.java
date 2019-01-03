package io.confluent.examples.authentication.oauth;

import org.apache.kafka.common.security.oauthbearer.OAuthBearerToken;

import java.util.HashSet;
import java.util.Set;

public class MyOauthBearerToken implements OAuthBearerToken {

    private long lifetimeMs;
    private String value;
    private long startTimeMs;
    private HashSet<String> scopes = new HashSet<>();

    MyOauthBearerToken() {
        this.lifetimeMs = System.currentTimeMillis() + 1000 * 60 * 60;
        this.value = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c";
        this.startTimeMs = System.currentTimeMillis();
        scopes.add("scope1");
        scopes.add("scope2");
    }

    @Override
    public String value() {
        return this.value;
    }

    @Override
    public Set<String> scope() {
        return scopes;
    }

    @Override
    public long lifetimeMs() {
        return this.lifetimeMs;
    }

    @Override
    public String principalName() {
        return "sub";
    }

    @Override
    public Long startTimeMs() {
        return startTimeMs;
    }
}
