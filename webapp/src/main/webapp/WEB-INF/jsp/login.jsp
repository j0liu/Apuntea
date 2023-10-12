<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fragment" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>

<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">

<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>Apuntea | <spring:message code="login.title"/></title>
    <link rel="shortcut icon" type="image/x-icon" href="<c:url value="/image/teacher.png"/>">

    <link rel="stylesheet" href="<c:url value="/css/main.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/general/elements.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/general/sizes.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/general/backgrounds.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/general/texts.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/general/buttons.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/general/icons.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/general/boxes.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/sections/navbar.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/sections/user/register-login.css"/>"/>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Lato:wght@400;700;900&display=swap" rel="stylesheet">

</head>

<body>

<header>
    <!-- NAVBAR -->
    <fragment:navbar loggedIn="${false}" isAdmin="${false}"/>

    <c:url var="loginUrl" value="/login"/>
    <spring:message var="logotype" code="logotype"/>

</header>

<section class="login-register-container container d-flex flex-column justify-content-center align-items-center">

    <div class="row">
        <div class="card box">
            <div class="row">
                <div class="col-lg-6">
                    <div class="card-body p-3 p-md-5 mx-4">

                        <form action="${loginUrl}" method="post">
                            <h1><spring:message code="login.title"/></h1>

                            <div class="">
                                <spring:message var="loginEmail" code="email"/>
                                <label for="email"></label>
                                <input type="text" name="email" id="email" class="form-control bg-bg"
                                       placeholder="${loginEmail}"/>
                            </div>

                            <label for="password"></label>
                            <div class="input-group">
                                <spring:message var="loginPassword" code="password"/>
                                <input type="password" name="password" id="password" class="form-control bg-bg"
                                       placeholder="${loginPassword}"/>
                                <span class="input-group-text input-group-icon clickable"
                                      onclick="password_show_hide();">
                                    <img src="<c:url value="/svg/eye.svg"/>" alt="" id="show_eye"
                                         class="icon-xs fill-dark-primary"/>
                                    <img src="<c:url value="/svg/eye-crossed.svg"/>" alt="" id="hide_eye"
                                         class="d-none icon-xs fill-dark-primary"/>
                                </span>
                            </div>

                            <c:if test="${param.error}">
                                <div class="text-danger mt-2" role="alert">
                                    <spring:message code="login.error"/>
                                </div>
                            </c:if>
                            <c:if test="${param.banned}">
                                <div class="text-danger mt-2" role="alert">
                                    <spring:message code="login.banned"/>
                                </div>
                            </c:if>

                            <div class="mt-4 d-flex align-items-center">
                                <input class="form-check-input" type="checkbox" name="rememberMe" id="rememberMe"/>
                                <label class="form-check-label mx-1" for="rememberMe"> <spring:message
                                        code="login.rememberMe"/> </label>
                            </div>

                            <div class="mt-3 d-flex justify-content-center">
                                <spring:message var="login" code="login.title"/>
                                <input class="btn rounded-box button-primary" type="submit" value="${login}">
                            </div>

                        </form>

                        <div class="d-flex align-items-center justify-content-center mt-4">
                            <p class="mb-0 me-2"><spring:message code="login.dontHave"/></p>
                            <a href="./register">
                                <button type="button" class="btn login-register-button box"><spring:message
                                        code="login.createNew"/></button>
                            </a>
                        </div>

                        <div class="d-flex align-items-center justify-content-center mt-4">
                            <a href="./forgot-password">
                                <p class="mb-0 me-2 link-info"><spring:message code="login.forgotPassword"/></p>
                            </a>
                        </div>

                    </div>
                </div>

                <div class="col-lg-6 box d-flex align-items-center we-are-more-container">
                    <div class="text-center px-5 py-5 ">
                        <div class="text-center mb-5">
                            <img src="<c:url value="/image/teacher.png"/>" alt="${logotype}"
                                 style="width: 40px; height: 40px;">
                            <h3 class="mt-1 text-bg"><spring:message code="login.weAre"/></h3>
                        </div>
                        <h4 class="mb-4"><spring:message code="login.weAreMore.title"/></h4>
                        <p><spring:message code="login.weAreMore.subtitle"/></p>
                    </div>
                </div>
            </div>
        </div>
    </div>

</section>

<div class="toast-container position-fixed bottom-0 end-0 p-3">
    <div id="liveToastRegister" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
        <div class="toast-body justify-content-between d-flex">
            <span><spring:message code="toast.registerSucceeded"/></span>
            <button type="button" class="btn-close align-content-center" data-bs-dismiss="toast"
                    aria-label="Close"></button>
        </div>
    </div>
</div>

<div class="toast-container position-fixed bottom-0 end-0 p-3">
    <div id="liveToastForgotPassword" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
        <div class="toast-body justify-content-between d-flex">
            <span><spring:message code="toast.forgotPasswordSucceeded"/></span>
            <button type="button" class="btn-close btn-close-white align-content-center" data-bs-dismiss="toast"
                    aria-label="Close"></button>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-HwwvtgBNo3bZJJLYd8oVXjrBZt8cqVSpeBNS5n7C8IVInixGAoxmnlMuBnhbgrkm"
        crossorigin="anonymous"></script>

<script src="<c:url value="/js/password.js"/>"></script>

<c:if test="${success eq true}">
    <script>
        const toastBootstrap = bootstrap.Toast.getOrCreateInstance(document.getElementById('liveToastRegister'));
        toastBootstrap.show();
    </script>
</c:if>

<c:if test="${not empty email }">
    <script>
        const toastBootstrap = bootstrap.Toast.getOrCreateInstance(document.getElementById('liveToastForgotPassword'));
        toastBootstrap.show();
    </script>
</c:if>

</body>

</html>