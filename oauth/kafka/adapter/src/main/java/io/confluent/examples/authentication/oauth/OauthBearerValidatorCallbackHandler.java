package io.confluent.examples.authentication.oauth;

import org.apache.kafka.common.security.auth.AuthenticateCallbackHandler;
import org.apache.kafka.common.security.oauthbearer.OAuthBearerValidatorCallback;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.security.auth.callback.Callback;
import javax.security.auth.callback.UnsupportedCallbackException;
import javax.security.auth.login.AppConfigurationEntry;
import java.io.IOException;
import java.util.List;
import java.util.Map;

public class OauthBearerValidatorCallbackHandler implements AuthenticateCallbackHandler {

    private final Logger log = LoggerFactory.getLogger(OauthBearerValidatorCallbackHandler.class);

    @Override
    public void configure(Map<String, ?> configs, String saslMechanism, List<AppConfigurationEntry> jaasConfigEntries) {

    }

    @Override
    public void close() {

    }

    @Override
    public void handle(Callback[] callbacks) throws IOException, UnsupportedCallbackException {
        log.info("Validating token.");
        for (Callback callback : callbacks) {
            if (callback instanceof OAuthBearerValidatorCallback) {
                OAuthBearerValidatorCallback oAuthBearerValidatorCallback = (OAuthBearerValidatorCallback) callback;
                log.info("Tokenvalue: {}", oAuthBearerValidatorCallback.tokenValue());
                oAuthBearerValidatorCallback.token(new MyOauthBearerToken());
                log.warn("Not yet implemented");
                ((OAuthBearerValidatorCallback) callback).token(new MyOauthBearerToken());
                continue;
            }
            throw new UnsupportedCallbackException(callback);
        }
    }
}
