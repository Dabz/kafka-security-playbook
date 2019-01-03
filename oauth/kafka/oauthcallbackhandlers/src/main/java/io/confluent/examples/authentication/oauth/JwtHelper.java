package io.confluent.examples.authentication.oauth;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;

import java.io.UnsupportedEncodingException;
import java.util.Arrays;
import java.util.Date;
import java.util.HashSet;

public class JwtHelper {

    String createJwt() throws UnsupportedEncodingException {
        return Jwts.builder()
                .setSubject("bene")
                .setExpiration(new Date(System.currentTimeMillis() + 1000 * 60 * 60))
                .claim("name", "Benedikt")
                .claim("scope", "developer admin")
                .setNotBefore(new Date())
                .setIssuedAt(new Date())
                .signWith(
                        SignatureAlgorithm.HS256,
                        "secret".getBytes("UTF-8")
                ).compact();
    }

    MyOauthBearerToken validate(String jwt) throws UnsupportedEncodingException {
        Jws<Claims> claims = Jwts.parser()
                .setSigningKey("secret".getBytes("UTF-8"))
                .parseClaimsJws(jwt);
        MyOauthBearerToken token = new MyOauthBearerToken();
        token.setLifetimeMs(claims.getBody().getExpiration().getTime());
        token.setPrincipalName(claims.getBody().getSubject());
        token.setScopes(new HashSet<>(Arrays.asList(((String) claims.getBody().get("scope")).split(" "))));
        token.setStartTimeMs(claims.getBody().getIssuedAt().getTime());
        token.setValue(jwt);
        return token;
    }


}
