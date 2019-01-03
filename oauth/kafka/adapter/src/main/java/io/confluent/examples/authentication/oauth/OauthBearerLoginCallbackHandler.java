package io.confluent.examples.authentication.oauth;

import org.apache.kafka.common.security.auth.AuthenticateCallbackHandler;
import org.apache.kafka.common.security.oauthbearer.OAuthBearerTokenCallback;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.security.auth.callback.Callback;
import javax.security.auth.callback.UnsupportedCallbackException;
import javax.security.auth.login.AppConfigurationEntry;
import java.util.List;
import java.util.Map;

public class OauthBearerLoginCallbackHandler implements AuthenticateCallbackHandler {

    private final Logger log = LoggerFactory.getLogger(OauthBearerLoginCallbackHandler.class);

    @Override
    public void configure(Map<String, ?> configs, String saslMechanism, List<AppConfigurationEntry> jaasConfigEntries) {

    }

    @Override
    public void close() {

    }

    @Override
    public void handle(Callback[] callbacks) throws UnsupportedCallbackException {
        log.info("Handling callbacks.");
        for (Callback callback : callbacks) {
            if (callback instanceof OAuthBearerTokenCallback) {
                OAuthBearerTokenCallback oAuthBearerTokenCallback = (OAuthBearerTokenCallback) callback;
                // TODO: retrieve token from authorization server
                oAuthBearerTokenCallback.token(new MyOauthBearerToken());
                continue;
            }
            throw new UnsupportedCallbackException(callback);
        }

    }
}


