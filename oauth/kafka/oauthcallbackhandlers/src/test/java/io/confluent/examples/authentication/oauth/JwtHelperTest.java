package io.confluent.examples.authentication.oauth;

import org.junit.Test;

import java.io.UnsupportedEncodingException;
import java.util.Arrays;
import java.util.HashSet;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

public class JwtHelperTest {

    @Test
    public void test() throws UnsupportedEncodingException {
        JwtHelper underTest = new JwtHelper();
        String jwt = underTest.createJwt();
        MyOauthBearerToken parsed = underTest.validate(jwt);
        System.err.println(parsed);
        assertEquals("bene", parsed.getPrincipalName());
        assertEquals(new HashSet<>(Arrays.asList("developer", "admin")), parsed.getScopes());
        assertTrue(parsed.getStartTimeMs() <= System.currentTimeMillis());
        assertTrue(parsed.getLifetimeMs() > System.currentTimeMillis());
    }
}
