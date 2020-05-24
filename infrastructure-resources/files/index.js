"use strict";

const { freeze } = Object;

const header = (key, value) => freeze([freeze({key, value})]);

const contentSecurityPolicy = header(
    "Content-Security-Policy",
    "style-src 'self'; img-src 'self'; font-src 'self'; script-src 'self'; default-src 'none'; sandbox allow-scripts allow-same-origin",
);

const crossOriginResourcePolicy = header(
    "Cross-Origin-Resource-Policy",
    "same-site",
);

const expectCertificateTransparency = header(
    "Expect-CT",
    "max-age=86400, enforce",
);

const featurePolicy = header(
    "Feature-Policy",
    "ambient-light-sensor 'none'; autoplay 'none'; accelerometer 'none'; camera 'none'; display-capture 'none'; document-domain 'none'; encrypted-media 'none'; fullscreen 'none'; geolocation 'none'; gyroscope 'none'; microphone 'none'; midi 'none'; payment 'none'; picture-in-picture 'none'; speaker 'none'; sync-xhr 'none'; usb 'none'; wake-lock 'none'; webauthn 'none'; vr 'none'",
);

const xssProtection = header(
    "X-XSS-Protection",
    "1; mode=block",
);

const frameOptions = header(
    "X-Frame-Options",
    "deny",
);

const referrerPolicy = header(
    "Referrer-Policy",
    "no-referrer",
);

const strictTransportSecurity = header(
    "Strict-Transport-Security",
    "max-age=31536000; includeSubDomains; preload",
);

const contentTypeOptions = header(
    "X-Content-Type-Options",
    "nosniff",
);

const uaCompatible = header(
    "X-UA-Compatible",
    "IE=edge",
);

exports.handler = async (event, context) => {
    const response = event.Records[0].cf.response;
    const headers = response.headers;

    headers["content-security-policy"] = contentSecurityPolicy;
    headers["cross-origin-resource-policy"] = crossOriginResourcePolicy;
    headers["expect-ct"] = expectCertificateTransparency;
    headers["feature-policy"] = featurePolicy;
    headers["x-xss-protection"] = xssProtection;
    headers["x-frame-options"] = frameOptions;
    headers["referrer-policy"] = referrerPolicy;
    headers["strict-transport-security"] = strictTransportSecurity;
    headers["x-Content-Type-Options"] = contentTypeOptions;
    headers["x-ua-compatible"] = uaCompatible;

    return response;
};

