package io.confluent.examples.authentication.oauth;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import org.apache.kafka.common.security.auth.AuthenticateCallbackHandler;
import org.apache.kafka.common.security.oauthbearer.OAuthBearerTokenCallback;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.security.auth.callback.Callback;
import javax.security.auth.callback.UnsupportedCallbackException;
import javax.security.auth.login.AppConfigurationEntry;
import java.io.UnsupportedEncodingException;
import java.util.Date;
import java.util.List;
import java.util.Map;

public class OauthBearerLoginCallbackHandler implements AuthenticateCallbackHandler {

    private final Logger log = LoggerFactory.getLogger(OauthBearerLoginCallbackHandler.class);

    private JwtHelper jwtHelper = new JwtHelper();

    @Override
    public void configure(Map<String, ?> configs, String saslMechanism, List<AppConfigurationEntry> jaasConfigEntries) {

    }

    @Override
    public void close() {

    }

    @Override
    public void handle(Callback[] callbacks) throws UnsupportedCallbackException, UnsupportedEncodingException {
        log.info("Handling callbacks.");
        for (Callback callback : callbacks) {
            if (callback instanceof OAuthBearerTokenCallback) {
                OAuthBearerTokenCallback oAuthBearerTokenCallback = (OAuthBearerTokenCallback) callback;
                // TODO: a bearer token would usually be retrieved from an authorization server.
                oAuthBearerTokenCallback.token(new MyOauthBearerToken(jwtHelper.createJwt()));
                log.info("Created jwt compact form");
                continue;
            }
            throw new UnsupportedCallbackException(callback);
        }

    }
}


