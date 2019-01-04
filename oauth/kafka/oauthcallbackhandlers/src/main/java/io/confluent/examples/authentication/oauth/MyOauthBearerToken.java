package io.confluent.examples.authentication.oauth;

import lombok.Data;
import org.apache.kafka.common.security.oauthbearer.OAuthBearerToken;

import java.util.HashSet;
import java.util.Set;

@Data
public class MyOauthBearerToken implements OAuthBearerToken {

    private long lifetimeMs;
    private String value;
    private long startTimeMs;
    private String principalName;
    private Set<String> scopes = new HashSet<>();

    MyOauthBearerToken() { }

    MyOauthBearerToken(String value) {
        this.value = value;
        this.lifetimeMs = System.currentTimeMillis() + 1000 * 60 * 60;
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
        return this.principalName;
    }

    @Override
    public Long startTimeMs() {
        return startTimeMs;
    }
}
