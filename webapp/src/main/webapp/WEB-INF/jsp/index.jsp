<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fragment" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>

<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">

<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>Apuntea</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css" rel="stylesheet"
          integrity="sha384-4bw+/aepP/YC94hEpVNVgiZdgIC5+VKNBQNGCHeKRQN+PtmoHDEXuppvnDJzQIu9" crossorigin="anonymous">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/js/bootstrap.bundle.min.js"
            integrity="sha384-HwwvtgBNo3bZJJLYd8oVXjrBZt8cqVSpeBNS5n7C8IVInixGAoxmnlMuBnhbgrkm"
            crossorigin="anonymous"></script>

    <link rel="stylesheet" href="<c:url value="/css/main.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/general/elements.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/general/sizes.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/general/backgrounds.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/general/texts.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/general/buttons.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/general/icons.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/general/boxes.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/sections/navbar.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/sections/landing/graph.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/sections/landing/carousel.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/sections/landing/comments.css"/>"/>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Lato:wght@400;700;900&display=swap" rel="stylesheet">

</head>
<body>

<!-- NAVBAR -->
<fragment:navbar/>

<!-- "¿SABÍAS QUÉ?" SECTION -->
<div class="container mt-5 mw-500">
    <div class="card bg-transparent border-0">
        <div class="card-body">
            <h5 class="card-title fw-bold"><spring:message code="index.dyk.title"/></h5>
            <div class="d-flex align-items-center mb-3">
                <img src="image/teacher.png" alt="Teacher" class="me-2" style="width: 40px; height: 40px;">
                <p class="mb-0"><spring:message code="index.dyk.subtitle"/></p>
            </div>
            <div class="d-flex align-items-center mb-3">
                <input type="text" class="form-control custom-input me-2 rounded-box bg-bg"
                       placeholder="<spring:message code="index.search.placeholder"/>">
                <button class="btn rounded-box button-white">
                    <spring:message code="index.search.button"/>
                </button>
            </div>
        </div>
    </div>
</div>

<!-- "EXPLORA NUESTRAS OPCIONES" SECTION -->
<div class="container mw-500">
    <div class="card bg-transparent border-0">
        <div class="card-body d-flex flex-column align-items-center">
            <div class="d-flex align-items-center mb-3">
                <img src="<c:url value="/svg/rocket.svg"/>" alt="Rocket" class="me-2 icon-s fill-text">
                <h5 class="fw-bold"><spring:message code="index.explore.title"/></h5>
            </div>
            <div class="d-flex w-75 justify-content-around">
                <!-- TODO: Change to index.explore.register again -->

                <button class="btn rounded-box button-primary" data-bs-toggle="modal" data-bs-target="#uploadModal">
                    <spring:message code="index.explore.upload"/></button>

                <div class="modal fade" id="uploadModal" data-bs-backdrop="static" data-bs-keyboard="false"
                     tabindex="-1" aria-labelledby="uploadLabel" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered">
                        <div class="modal-content box bg-bg">
                            <div class="modal-header">
                                <h1 class="modal-title fs-5" id="uploadLabel"><spring:message
                                        code="modal.upload.title"/></h1>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"
                                        aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <!-- CREATE NOTE FORM -->
                                <c:url var="createUrl" value="/create"/>
                                <form:form modelAttribute="createNoteForm" action="${createUrl}" method="post" enctype="multipart/form-data" class="d-flex flex-column gap-4">
                                    <div class="d-flex flex-column gap-2">
                                        <div class="input-group">
                                        <label class="input-group-text" for="file"><spring:message code="form.upload.file"/></label>
                                        <form:input path="file" type="file" class="form-control" id="file"/>
                                        </div>
                                        <form:errors path="file" cssClass="text-danger" element="p"/>
                                    </div>

                                    <div class="d-flex flex-column gap-2">
                                        <div class="input-group">
                                            <label class="input-group-text" for="name"><spring:message code="form.upload.name"/></label>
                                            <form:input path="name" type="text" aria-label="<spring:message code=\"form.upload.name\"/>" class="form-control" id="name"/>
                                        </div>
                                        <form:errors path="name" cssClass="text-danger" element="p"/>
                                    </div>

                                    <div class="d-flex flex-column gap-2">
                                        <div class="input-group">
                                            <form:select path="institution" id="institutionSelect" style="">
                                                <form:option value="all"><spring:message code="form.upload.institution"/></form:option>
                                                <c:forEach items="${institutions}" var="inst">
                                                    <form:option value="${inst.name}">${inst.name}</form:option>
                                                </c:forEach>
                                            </form:select>

                                            <input type="text" id="institutionInput" placeholder="Type to filter institutions">
                                            <input type="hidden" id="selectedInstitution" name="selectedInstitution">
                                        </div>
                                    </div>

                                    <div class="d-flex flex-column gap-2">
                                        <div class="input-group">
                                            <label class="input-group-text" for="career"><spring:message code="form.upload.career"/></label>
                                            <form:input path="career" type="text" aria-label="<spring:message code=\"form.upload.career\"/>" class="form-control" id="career"/>
                                        </div>
                                        <form:errors path="career" cssClass="text-danger" element="p"/>
                                    </div>

                                    <div class="d-flex flex-column gap-2">
                                        <div class="input-group">
                                            <label class="input-group-text" for="subject"><spring:message code="form.upload.subject"/></label>
                                            <form:input path="subject" type="text" aria-label="<spring:message code=\"form.upload.subject\"/>" class="form-control" id="subject"/>
                                        </div>
                                        <form:errors path="subject" cssClass="text-danger" element="p"/>
                                    </div>

                                    <div class="d-flex flex-column gap-2">
                                        <div class="input-group">
                                            <label class="input-group-text" for="category"><spring:message code="form.upload.category"/></label>
                                            <form:select path="category" class="form-select" id="category">
                                                <form:option value="all"><spring:message code="form.upload.category"/></form:option>
                                                <form:option value="theory"><spring:message code="search.category.theory"/></form:option>
                                                <form:option value="practice"><spring:message code="search.category.practice"/></form:option>
                                                <form:option value="exam"><spring:message code="search.category.exam"/></form:option>
                                            </form:select>
                                        </div>
                                        <form:errors path="category" cssClass="text-danger" element="p"/>
                                    </div>

                                    <div class="modal-footer">
                                        <button type="button" class="btn rounded-box button-primary" data-bs-dismiss="modal">
                                            <spring:message code="button.close"/></button>
                                        <input type="submit" class="btn rounded-box button-secondary" value="<spring:message
                                            code="button.upload"/>"/>
                                    </div>
                                </form:form>
                            </div>
                        </div>
                    </div>
                </div>

                <a href="search">
                    <button class="btn rounded-box button-secondary">
                        <spring:message code="index.explore.discover"/></button>
                </a>
            </div>
        </div>
    </div>
</div>


<div class="row mt-5 m-0 ">
    <!-- CARROUSEL LAST NOTES -->
    <div class="d-flex flex-column col-xl-6">
        <div class="d-flex justify-content-center" style="padding-left: 40px;">
            <h5 class="fw-bold" style="margin-left: 120px; margin-right: 75px"><spring:message
                    code="index.notes.title"/></h5>
            <div>
                <button class="carousel-button" type="button" data-bs-target="#carouselUniversity" data-bs-slide="prev">
                    <img src="<c:url value="/svg/prev.svg"/>" alt="Previous" class="icon-l fill-dark-primary">
                </button>
                <button class="carousel-button" type="button" data-bs-target="#carouselUniversity" data-bs-slide="next">
                    <img src="<c:url value="/svg/next.svg"/>" alt="Next" class="icon-l fill-dark-primary">
                </button>
            </div>

        </div>

        <div id="carouselUniversity" class="carousel slide mt-3">
            <div class="carousel-inner">
                <!-- First "page" of carrousel -->
                <div class="carousel-item mb-5 active">
                    <!-- University name and graph -->
                    <div class="container mw-600">
                        <div class="card box h-100 bg-bg">
                            <div class="card-body d-flex align-items-center h-100 justify-content-around flex-wrap">
                                <!-- University Icon and Name (in the right) -->
                                <div class="d-flex align-items-center university-title ">
                                    <img src="<c:url value="/svg/graduation-cap.svg"/>" alt="University Icon" class="icon-s fill-text">
                                    <h5 class=" mx-2 w-100"><strong>PLACEHOLDER</strong></h5>
                                </div>
                                <!-- Graph with circles and lines -->
                                <div class="graph h-100">
                                    <div class="circle circle1"></div>
                                    <div class="line line1"></div>
                                    <div class="circle circle2"></div>
                                    <div class="line line2"></div>
                                    <div class="circle circle3"></div>
                                    <div class="line line3"></div>
                                    <div class="circle circle4"></div>
                                    <div class="line line4"></div>
                                    <div class="circle circle5"></div>
                                    <div class="info1 d-flex flex-column fw-bold text-center w-25">
                                        <p>NUMBER</p>
                                        <p><spring:message code="index.notes.students"/></p>
                                    </div>
                                    <div class="info2 d-flex flex-column fw-bold text-center w-25">
                                        <p>NUMBER</p>
                                        <p><spring:message code="index.notes.notes"/></p>
                                    </div>
                                    <!-- Add more circles and lines as needed -->
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- Example notes -->
                    <div class="container mw-600">
                        <div class="card box h-100 py-1 bg-dark-bg">
                            <div class="card-body d-flex flex-column gap-2">
                                <a href="https://www.google.com" class="bar-link">
                                    <button class="btn rounded-pill button-white button-expansion
                          w-100 d-flex align-items-center text-s">
                                        <span class="col-4 text-start">PLACEHOLDER</span>
                                        <span class="col-6">PLACEHOLDER</span>
                                        <span class="col-2 text-end">PLACEHOLDER</span>
                                    </button>
                                </a>
                                <a href="https://www.google.com" class="bar-link">
                                    <button class="btn rounded-pill button-white button-expansion
                          w-100 d-flex justify-content-between align-items-center text-s">
                                        <span class="col-4 text-start">PLACEHOLDER</span>
                                        <span class="col-6">PLACEHOLDER</span>
                                        <span class="col-2 text-end">PLACEHOLDER</span>
                                    </button>
                                </a>
                                <a href="https://www.google.com" class="bar-link">
                                    <button class="btn rounded-pill button-white button-expansion
                          w-100 d-flex justify-content-between align-items-center text-s">
                                        <span class="col-4 text-start">PLACEHOLDER</span>
                                        <span class="col-6">PLACEHOLDER</span>
                                        <span class="col-2 text-end">PLACEHOLDER</span>
                                    </button>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>

        <!-- LIST LAST COMMENTS -->
        <div id="last-comments" class="d-flex flex-column col-xl-6">
            <h5 class="text-center fw-bold"><spring:message code="index.comments.title"/></h5>
            <div class="container mt-3">
                <div class="row justify-content-center">
                    <!-- A COMMENT -->
                    <div class="col-lg-12 col-xl-6 mb-4 mw-500">
                        <a href="https://www.google.com" class="card box h-100 text-decoration-none button-shadow">
                            <div class="card-body">
                                <h5 class="card-title fb-">
                                    <img src="/svg/arrow-trend-up.svg" alt="University Icon" class="icon-s fill-dark-primary mx-2">
                                    <strong>Matemática Discreta</strong>
                                </h5>
                                <p class="card-text"><strong>Jonathan ha comentado</strong></p>
                                <p class="card-text mt-2">Buen apunte, pero el de Apuntes Britu es mejor.</p>
                            </div>
                        </a>
                    </div>
                    <!-- A COMMENT -->
                    <div class="col-lg-12 col-xl-6 mb-4 mw-500">
                        <a href="https://www.google.com" class="card box h-100 text-decoration-none button-shadow">
                            <div class="card-body">
                                <h5 class="card-title fb-">
                                    <img src="/svg/arrow-trend-up.svg" alt="University Icon" class="icon-s fill-dark-primary mx-2">
                                    <strong>Teoría de Lenguajes y Autómatas</strong>
                                </h5>
                                <p class="card-text"><strong>David ha comentado</strong></p>
                                <p class="card-text mt-2">El de Apuntes Abru le pasa el trapo, aunque pesa 100MB más...</p>
                            </div>
                        </a>
                    </div>
                    <!-- A COMMENT -->
                    <div class="col-lg-12 col-xl-6 mb-4 mw-500">
                        <a href="https://www.google.com" class="card box h-100 text-decoration-none button-shadow">
                            <div class="card-body">
                                <h5 class="card-title fb-">
                                    <img src="/svg/arrow-trend-up.svg" alt="University Icon" class="icon-s fill-dark-primary mx-2">
                                    <strong>Matemática III</strong>
                                </h5>
                                <p class="card-text"><strong>Tomás ha comentado</strong></p>
                                <p class="card-text mt-2">Muy bueno!</p>
                            </div>
                        </a>
                    </div>

                </div>
            </div>
        </div>
    </div>

<script src="<c:url value="/js/scripts.js"/>"></script>
</body>

</html>