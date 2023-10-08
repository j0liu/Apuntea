<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fragment" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<spring:eval expression="@environment.getProperty('base.url')" var="baseUrl"/>

<c:set var="colors" value="${fn:split('BBBBBB,16A765,4986E7,CD35A6', ',')}"/> <!-- TODO: ADD MORE COLORS -->

<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">

<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title> Apuntea | <c:out value="${directory.name}"/></title>
    <link rel="shortcut icon" type="image/x-icon" href="<c:url value="/image/teacher.png"/>">

    <link rel="stylesheet" href="<c:url value="/css/main.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/general/elements.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/general/sizes.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/general/backgrounds.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/general/autocomplete.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/general/texts.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/general/buttons.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/general/color-picker.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/general/icons.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/general/boxes.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/sections/navbar.css"/>"/>
    <link rel="stylesheet" href="<c:url value="/css/sections/search/table-list.css"/>"/>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Lato:wght@400;700;900&display=swap" rel="stylesheet">

</head>
<body>

<fragment:navbar loggedin="${user != null}"/>

<fragment:bottom-navbar hierarchy="${hierarchy}"/>

<c:url var="createUrl" value="./${directoryId}"/>

<!-- SEARCH -->
<div class="container my-5">
    <c:url var="searchUrl" value="./${directoryId}"/>
    <form:form modelAttribute="navigationForm"
               action="${searchUrl}"
               method="get"
               id="searchForm"
               cssClass="d-flex flex-column">
        <div class="row row-cols-1 row-cols-md-3">

            <div class="col">
                <div class="input-group mb-3">
                    <form:select path="category" class="form-select bg-bg" id="categorySelect">
                        <form:option value=""><spring:message code="search.category.all"/></form:option>
                        <form:option value="directory"><spring:message code="search.category.folder"/></form:option>
                        <form:option value="theory"><spring:message code="search.category.theory"/></form:option>
                        <form:option value="practice"><spring:message code="search.category.practice"/></form:option>
                        <form:option value="exam"><spring:message code="search.category.exam"/></form:option>
                        <form:option value="other"><spring:message code="search.category.other"/></form:option>
                    </form:select>
                </div>
            </div>

            <div class="col">
                <div class="input-group mb-3">
                    <span class="input-group-text input-group-icon clickable">
                        <form:checkbox path="ascending" id="ascCheckbox" cssClass="d-none"/>
                            <c:if test="${navigationForm.ascending}">
                                <img src="<c:url value="/svg/arrow-up.svg"/>"
                                     alt="<spring:message code="search.sort.image"/>"
                                     class="icon-s fill-dark-primary"
                                     id="arrowImage" title="ascending"/>
                            </c:if>
                            <c:if test="${!navigationForm.ascending}">
                                <img src="<c:url value="/svg/arrow-down.svg"/>"
                                     alt="<spring:message code="search.sort.image"/>"
                                     class="icon-s fill-dark-primary"
                                     id="arrowImage" title="descending"/>
                            </c:if>
                    </span>

                    <form:select path="sortBy" class="form-select bg-bg" id="sortBySelect">
                        <form:option value="score"><spring:message code="search.sort.score"/></form:option>
                        <%--                        <form:option value=""><spring:message code="search.sort.placeholder"/></form:option>--%>
                        <form:option value="name"><spring:message code="search.sort.name"/></form:option>
                        <form:option value="date"><spring:message code="search.sort.date"/></form:option>
                    </form:select>
                </div>
            </div>

            <div class="col">
                <div class="input-group mb-3">
                    <spring:message code="search.word.placeholder" var="placeholderSearch"/>
                    <form:input path="word" type="text" class="form-control bg-bg" placeholder='${placeholderSearch}'/>
                </div>
            </div>


            <form:hidden path="pageNumber" id="pageNumber"/>
            <form:hidden path="pageSize" id="pageSize"/>

        </div>

        <div class="w-25 align-self-center">
            <button type="submit" class="btn button-primary w-100"><spring:message code="search.button"/></button>
        </div>

    </form:form>

</div>

<c:if test="${empty results}">
    <section class="container text-center mt-4 d-flex flex-column align-items-center gap-2">
        <div class="d-flex align-middle gap-2 justify-content-center">
            <img src="<c:url value="/image/no-task.png"/>" alt="Empty Folder" class="icon-xl"/>
            <h3><spring:message code="directories.noContent"/></h3>
        </div>
        <c:if test="${user ne null and (directory.user eq null or directory.user.userId eq user.userId)}">
            <p class="text-muted"><spring:message code="directories.noContent.description"/></p>
            <div class="d-flex gap-2">
                <a href="#" data-bs-toggle="tooltip" data-bs-placement="bottom"
                   data-bs-title="<spring:message code="uploadNote"/>"
                   data-bs-trigger="hover">
                    <button class="btn nav-icon-button" data-bs-toggle="modal" data-bs-target="#createNoteModal"
                            id="createNoteModalButton">
                        <img src="<c:url value="/svg/add-document.svg"/>"
                             alt="<spring:message code="uploadNote"/>"
                             class="icon-m fill-dark-primary"/>
                    </button>
                </a>

                <a href="#" data-bs-toggle="tooltip" data-bs-placement="bottom"
                   data-bs-title="<spring:message code="createDirectory"/>"
                   data-bs-trigger="hover">
                    <button class="btn nav-icon-button" data-bs-toggle="modal" data-bs-target="#createDirectoryModal"
                            id="createDirectoryModalButton">
                        <img src="<c:url value="/svg/add-folder.svg"/>"
                             alt="<spring:message code="createDirectory"/>"
                             class="icon-m fill-dark-primary"/>
                    </button>
                </a>
            </div>
        </c:if>
    </section>
</c:if>

<!-- LIST OF NOTES MATCHING -->
<c:if test="${not empty results}">
    <!-- DEFINES -->
    <spring:message code="download" var="download"/>
    <spring:message code="folder" var="folder"/>
    <spring:message code="search.toggleView" var="searchViewImage"/>
    <c:url value="/svg/box-list.svg" var="boxViewUrl"/>
    <c:url value="/svg/horizontal-list.svg" var="horizontalViewUrl"/>

    <!-- TOP BUTTONS -->
    <div class="d-flex container mt-4 justify-content-between p-0">
        <div class="d-flex">
            <c:if test="${user ne null and (directory.user eq null or directory.user.userId eq user.userId)}">
                <a href="#" data-bs-toggle="tooltip" data-bs-placement="bottom"
                   data-bs-title="<spring:message code="uploadNote"/>"
                   data-bs-trigger="hover">
                    <button class="btn nav-icon-button" data-bs-toggle="modal" data-bs-target="#createNoteModal"
                            id="createNoteModalButton">
                        <img src="<c:url value="/svg/add-document.svg"/>"
                             alt="<spring:message code="uploadNote"/>"
                             class="icon-m fill-dark-primary"/>
                    </button>
                </a>
                <a href="#" data-bs-toggle="tooltip" data-bs-placement="bottom"
                   data-bs-title="<spring:message code="createDirectory"/>"
                   data-bs-trigger="hover">
                    <button class="btn nav-icon-button" data-bs-toggle="modal" data-bs-target="#createDirectoryModal"
                            id="createDirectoryModalButton">
                        <img src="<c:url value="/svg/add-folder.svg"/>"
                             alt="<spring:message code="createDirectory"/>"
                             class="icon-m fill-dark-primary"/>
                    </button>
                </a>
            </c:if>
        </div>

        <div class="d-flex">
            <div id="selectedButtons" class="align-items-center" style="display: none;">
                <button id="deselectAllButton" class="btn nav-icon-button" type="button" data-bs-toggle="tooltip"
                        data-bs-placement="bottom" data-bs-title="<spring:message code="search.button.deselectAll"/>"
                        data-bs-trigger="hover">
                    <img src="<c:url value="/svg/cross.svg"/>" alt="deselect" class="icon-s fill-dark-primary"/>
                </button>
                <span class="text-dark-primary mx-2">
                    <strong id="selectedCount" class="text-dark-primary"> 0 </strong>
                    <spring:message code="search.selected"/>
                </span>

                <c:if test="${user ne null and directory.user ne null and directory.user.userId eq user.userId}">
                    <div data-bs-toggle="tooltip" data-bs-placement="bottom"
                         data-bs-title="<spring:message code="delete"/>" data-bs-trigger="hover">
                        <button id="openDeleteSelectedModalButton" class="btn nav-icon-button"
                                data-bs-toggle="modal" data-bs-target="#deleteManyModal">
                            <img src="<c:url value="/svg/trash.svg"/>"
                                 alt="<spring:message code="delete"/>"
                                 class="icon-s fill-dark-primary">
                        </button>
                    </div>
                </c:if>

                <button id="downloadSelectedButton" class="btn nav-icon-button" type="button" data-bs-toggle="tooltip"
                        data-bs-placement="bottom" data-bs-title="<spring:message code="download"/>"
                        data-bs-trigger="hover">
                    <img src="<c:url value="/svg/download.svg"/>" alt="download" class="icon-s fill-dark-primary"/>
                </button>
            </div>
            <button id="selectAllButton" class="btn nav-icon-button" type="button" data-bs-toggle="tooltip"
                    data-bs-placement="bottom" data-bs-title="<spring:message code="search.button.selectAll"/>"
                    data-bs-trigger="hover">
                <img src="<c:url value="/svg/list-check.svg"/>" alt="select all" class="icon-s fill-dark-primary"/>
            </button>
            <button id="searchViewToggle" class="btn nav-icon-button" type="button" data-bs-toggle="tooltip"
                    data-bs-placement="bottom" data-bs-title="<spring:message code="search.button.listView"/>"
                    data-horizontal="<spring:message code="search.button.listView"/>"
                    data-box="<spring:message code="search.button.boxView"/>" data-bs-trigger="hover">
                <img id="searchViewIcon" src="${horizontalViewUrl}" alt="${searchViewImage}"
                     class="icon-s fill-dark-primary"/>
            </button>
        </div>

    </div>

    <!-- HORIZONTAL LIST -->
    <section class="container mt-4 p-0" id="horizontalList">
        <div class="table-responsive">
            <table class="table table-hover table-search">
                <thead>
                <tr>
                    <th class="col-md-5"><spring:message code="name"/></th>
                    <th class="col-md-2"><spring:message code="owner"/></th>
                    <th class="col-md-1"><spring:message code="createdAt"/></th>
                    <th class="col-md-1"><spring:message code="score"/></th>
                    <th class="col-md-2"></th> <!-- ACTIONS -->
                    <!-- TODO: ADD SIZE OF FILE -->
                </tr>
                </thead>
                <tbody>
                <c:forEach var="item" items="${results}">
                    <c:set var="date" value="${item.createdAt}"/>
                    <tr class="note-found no-select"
                        data-category="<c:out value="${item.category.formattedName}"/>"
                        data-visible="${item.visible}"
                        id="<c:out value="${item.id}"/>.1">
                        <td class="note-found-title">
                            <c:if test="${item.category.formattedName ne 'directory'}">
                                <c:if test="${item.fileType eq 'pdf'}"> <!-- TODO: ADD MORE TYPES -->
                                    <img src="<c:url value="/image/pdf.png"/>" alt="pdf" class="icon-m">
                                </c:if>
                            </c:if>
                            <c:if test="${item.category.formattedName eq 'directory'}">
                                <img src="<c:url value="/svg/folder.svg"/>" alt="${folder}"
                                     data-color="${item.iconColor}"
                                     class="icon-m fill-${item.iconColor} folder-icon">
                            </c:if>
                            <span class="card-title align-middle mx-2 note-name">
                                <c:out value="${item.name}"/>
                            </span>
                        </td>
                        <td><c:out value="${item.user.email}"/></td>
                        <td><spring:message code="date.format"
                                            arguments="${date.year},${date.monthValue},${date.dayOfMonth}"/></td>
                        <td>
                            <c:if test="${item.avgScore eq 0}">
                                <spring:message code="notes.noScore"/>
                            </c:if>
                            <c:if test="${item.avgScore ne 0}">
                                <fmt:formatNumber type="number" maxFractionDigits="1" value="${item.avgScore}"/>
                            </c:if>
                        </td>


                        <td class="search-actions">
                            <div class="d-flex justify-content-end">
                                <!-- Favorite -->
                                <c:if test="${user ne null and item.category.formattedName eq 'directory'}"> <!-- TODO: Por ahora es directory nomas -->
                                    <c:set var="addFavorite" value="./${item.id}/addfavorite"/>
                                    <c:set var="removeFavorite" value="./${item.id}/removefavorite"/>

                                    <div data-bs-toggle="tooltip" data-bs-placement="bottom"
                                         data-bs-title="<spring:message code="favorite"/>" data-bs-trigger="hover">
                                        <form:form action="${item.favorite ? removeFavorite : addFavorite}"
                                                   method="post">
                                            <input name="parentId" value="${item.parentId}" type="hidden"/>
                                            <button type="submit"
                                                    class="btn nav-icon-button favorite-button"
                                                    data-bs-toggle="tooltip"
                                                    data-bs-placement="bottom"
                                                    data-bs-title="<spring:message code="favorite"/>"
                                                    id="<c:out value="${item.id}"/>.f1">
                                                <img src="<c:url value="${ item.favorite ?  '/svg/filled-heart.svg' : '/svg/heart.svg'}"/>"
                                                     alt="<spring:message code="favorite"/>"
                                                     class="icon-xs fill-text">
                                            </button>
                                        </form:form>
                                    </div>
                                </c:if>

                                <c:if test="${user ne null and item.user.userId eq user.userId}">
                                    <c:if test="${item.category.formattedName ne 'directory'}">
                                        <!-- EDIT -->
                                        <div data-bs-toggle="tooltip" data-bs-placement="bottom"
                                             data-bs-title="<spring:message code="edit"/>" data-bs-trigger="hover">
                                            <button class="btn nav-icon-button edit-button"
                                                    data-bs-toggle="modal" data-bs-target="#editNoteModal"
                                                    id="<c:out value="${item.id}"/>.e1">
                                                <img src="<c:url value="/svg/pencil.svg"/>"
                                                     alt="<spring:message code="edit"/>"
                                                     class="icon-xs fill-text">
                                            </button>
                                        </div>
                                    </c:if>
                                    <c:if test="${item.category.formattedName eq 'directory'}">
                                        <!-- EDIT -->
                                        <div href="#" data-bs-toggle="tooltip" data-bs-placement="bottom"
                                             data-bs-title="<spring:message code="edit"/>" data-bs-trigger="hover">
                                            <button class="btn nav-icon-button edit-button"
                                                    data-bs-toggle="modal" data-bs-target="#editDirectoryModal"
                                                    id="<c:out value="${item.id}"/>.e1">
                                                <img src="<c:url value="/svg/pencil.svg"/>"
                                                     alt="<spring:message code="edit"/>"
                                                     class="icon-xs fill-text">
                                            </button>
                                        </div>
                                    </c:if>
                                </c:if>

                                <c:if test="${item.category.formattedName ne 'directory'}"> <!-- FOLDERS CANNOT BE DOWNLOADED -->
                                    <a href="../notes/${item.id}/download" download="${item.name}">
                                        <button type="button" class="btn button-expansion rounded-circle"
                                                data-bs-toggle="tooltip" data-bs-placement="bottom"
                                                data-bs-title="<spring:message code="download"/>"
                                                data-bs-trigger="hover">
                                            <img src="<c:url value="/svg/download.svg"/>" alt="${download}"
                                                 class="icon-xs fill-text">
                                        </button>
                                    </a>
                                </c:if>

                                <!-- ALL CAN BE COPIED -->
                                <div>
                                    <button class="btn button-expansion rounded-circle copy-button"
                                            id="<c:out value="${item.id}"/>.c1"
                                            data-category=""
                                            data-bs-toggle="tooltip"
                                            data-bs-placement="bottom" data-bs-title="<spring:message code="copyLink"/>"
                                            data-bs-trigger="hover">
                                        <img src="<c:url value="/svg/link.svg"/>"
                                             alt="<spring:message code="copyLink"/>"
                                             class="icon-xs fill-text">
                                    </button>
                                </div>

                                <!-- DELETE -->
                                <c:if test="${user ne null and item.user.userId eq user.userId}">
                                    <div data-bs-toggle="tooltip" data-bs-placement="bottom"
                                         data-bs-title="<spring:message code="delete"/>" data-bs-trigger="hover">
                                        <button class="btn nav-icon-button delete-button"
                                                data-bs-toggle="modal" data-bs-target="#deleteManyModal"
                                                id="<c:out value="${item.id}"/>.d1">
                                            <img src="<c:url value="/svg/trash.svg"/>"
                                                 alt="<spring:message code="delete"/>"
                                                 class="icon-xs fill-text">
                                        </button>
                                    </div>
                                </c:if>
                            </div>
                            <input type="checkbox" class="select-checkbox d-none"/>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </section>

    <!-- BOX LIST -->
    <section class="container mt-4 p-0" id="boxList">
        <div class="row">
            <c:forEach items="${results}" var="item">
                <div class="col-md-4 mb-4">
                    <div class="note-found card box search-note-box h-100"
                         data-category="${item.category.formattedName}"
                         id="<c:out value="${item.id}"/>.2">
                        <div class="card-body no-select">

                            <!-- TITLE AND BUTTONS -->
                            <div class="d-flex justify-content-between">
                                <div class="d-flex gap-2 overflow-hidden align-items-center mb-2">
                                    <c:if test="${item.category.formattedName ne 'directory'}">
                                        <c:if test="${item.fileType eq 'pdf'}"> <!-- TODO: ADD MORE TYPES -->
                                            <img src="<c:url value="/image/pdf.png"/>" alt="pdf" class="icon-s">
                                        </c:if>
                                    </c:if>
                                    <c:if test="${item.category.formattedName eq 'directory'}">
                                        <img src="<c:url value="/svg/folder.svg"/>" alt="${folder}"
                                             class="icon-s fill-${item.iconColor}">
                                    </c:if>
                                    <h4 class="card-title text-truncate mb-0">
                                        <c:out value="${item.name}"/>
                                    </h4>
                                </div>


                                <div class="d-flex">

                                    <!-- FAVORITE -->
                                    <c:if test="${user ne null and item.category.formattedName eq 'directory'}"> <!-- TODO: Por ahora es directory nomas -->
                                        <c:set var="addFavorite" value="./${item.id}/addfavorite"/>
                                        <c:set var="removeFavorite" value="./${item.id}/removefavorite"/>

                                        <div data-bs-toggle="tooltip" data-bs-placement="bottom"
                                             data-bs-title="<spring:message code="favorite"/>" data-bs-trigger="hover">
                                            <form:form action="${item.favorite ? removeFavorite : addFavorite}"
                                                       method="post">
                                                <input name="parentId" value="${item.parentId}" type="hidden"/>
                                                <button type="submit"
                                                        class="btn nav-icon-button favorite-button"
                                                        data-bs-toggle="tooltip"
                                                        data-bs-placement="bottom"
                                                        data-bs-title="<spring:message code="favorite"/>"
                                                        id="<c:out value="${item.id}"/>.f1">
                                                    <img src="<c:url value="${ item.favorite ?  '/svg/filled-heart.svg' : '/svg/heart.svg'}"/>"
                                                         alt="<spring:message code="favorite"/>"
                                                         class="icon-xs fill-text">
                                                </button>
                                            </form:form>
                                        </div>
                                    </c:if>

                                    <c:if test="${user ne null and (item.user.userId eq user.userId)}">
                                        <c:if test="${item.category.formattedName ne 'directory'}">
                                            <a data-bs-toggle="tooltip" data-bs-placement="bottom" href="#"
                                               data-bs-title="<spring:message code="edit"/>" data-bs-trigger="hover">
                                                <button class="btn button-expansion rounded-circle edit-button"
                                                        data-bs-toggle="modal" data-bs-target="#editNoteModal"
                                                        id="<c:out value="${item.id}.e2"/>">

                                                    <img src="<c:url value="/svg/pencil.svg"/>"
                                                         alt="<spring:message code="edit"/>"
                                                         class="icon-xs fill-text">
                                                </button>
                                            </a>
                                        </c:if>
                                        <c:if test="${item.category.formattedName eq 'directory'}">
                                            <a data-bs-toggle="tooltip" data-bs-placement="bottom" href="#"
                                               data-bs-title="<spring:message code="edit"/>" data-bs-trigger="hover">
                                                <button class="btn button-expansion rounded-circle edit-button"
                                                        data-bs-toggle="modal" data-bs-target="#editDirectoryModal"
                                                        id="<c:out value="${item.id}.e2"/>">
                                                    <img src="<c:url value="/svg/pencil.svg"/>"
                                                         alt="<spring:message code="edit"/>"
                                                         class="icon-xs fill-text">
                                                </button>
                                            </a>
                                        </c:if>
                                        <div data-bs-toggle="tooltip" data-bs-placement="bottom"
                                             data-bs-title="<spring:message code="delete"/>" data-bs-trigger="hover">
                                            <button class="btn nav-icon-button delete-button"
                                                    data-bs-toggle="modal" data-bs-target="#deleteManyModal"
                                                    id="<c:out value="${item.id}"/>.e2">
                                                <img src="<c:url value="/svg/trash.svg"/>"
                                                     alt="<spring:message code="delete"/>"
                                                     class="icon-xs fill-text">
                                            </button>
                                        </div>
                                    </c:if>
                                </div>
                            </div>


                            <span class="card-text">
                                <strong><spring:message code="owner"/></strong>:
                                <c:out value="${item.user.email}"/>
                            </span>

                            <br>
                                <%--<span class="card-text"><strong><spring:message code="category"/></strong>:
                                    <c:if test="${item.category.formattedName eq 'theory'}">
                                        <spring:message code="search.category.theory"/>
                                    </c:if>
                                    <c:if test="${item.category.formattedName eq 'practice'}">
                                        <spring:message code="search.category.practice"/>
                                    </c:if>
                                    <c:if test="${item.category.formattedName eq 'exam'}">
                                        <spring:message code="search.category.exam"/>
                                    </c:if>
                                    <c:if test="${item.category.formattedName eq 'other'}">
                                        <spring:message code="search.category.other"/>
                                    </c:if>
                                </span>
                                <br>--%>
                            <span class="card-text">
                                <strong><spring:message code="createdAt"/></strong>:
                                <spring:message code="date.format"
                                                arguments="${date.year},${date.monthValue},${date.dayOfMonth}"/>
                            </span>

                            <br>

                            <span class="card-text">
                                <c:if test="${item.avgScore eq 0}">
                                    <strong><spring:message code="notes.noScore"/></strong>
                                </c:if>
                                <c:if test="${item.avgScore ne 0}">
                                    <strong><spring:message code="score"/></strong>:
                                    <fmt:formatNumber type="number" maxFractionDigits="1" value="${item.avgScore}"/>
                                </c:if>
                            </span>
                            <input type="checkbox" class="select-checkbox d-none"/>

                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </section>

    <!-- PAGINATION -->
    <section class="container d-flex justify-content-center mt-3">
        <nav aria-label="...">
            <ul class="pagination">
                <c:if test="${navigationForm.pageNumber gt 1}">
                    <li class="page-item">
                            <%--suppress XmlDuplicatedId --%>
                        <a class="page-link" id="previousPage"><spring:message code="search.pagination.previous"/></a>
                    </li>
                </c:if>
                <c:if test="${navigationForm.pageNumber le 1}">
                    <li class="page-item disabled">
                            <%--suppress XmlDuplicatedId --%>
                        <a class="page-link" id="previousPage"><spring:message code="search.pagination.previous"/></a>
                    </li>
                </c:if>

                <c:if test="${navigationForm.pageNumber gt 2}">
                    <li class="page-item">
                        <a class="page-link" data-page="1"><c:out value="1"/></a>
                    </li>
                </c:if>

                <c:if test="${navigationForm.pageNumber gt 3}">
                    <li class="page-item disabled">
                        <a class="page-link">...</a>
                    </li>
                </c:if>

                <c:if test="${navigationForm.pageNumber gt 1}">
                    <li class="page-item">
                        <a class="page-link" data-page="${navigationForm.pageNumber - 1}"><c:out value="${navigationForm.pageNumber - 1}"/></a>
                    </li>
                </c:if>

                <li class="page-item active" aria-current="page">
                    <a class="page-link" data-page="${navigationForm.pageNumber}"><c:out value="${navigationForm.pageNumber}"/></a>
                </li>

                <c:if test="${navigationForm.pageNumber lt maxPage}">
                    <li class="page-item">
                        <a class="page-link" data-page="${navigationForm.pageNumber + 1}"><c:out value="${navigationForm.pageNumber + 1}"/></a>
                    </li>
                </c:if>

                <c:if test="${navigationForm.pageNumber lt maxPage - 2}">
                    <li class="page-item disabled">
                        <a class="page-link">...</a>
                    </li>
                </c:if>

                <c:if test="${navigationForm.pageNumber lt maxPage - 1}">
                    <li class="page-item">
                        <a class="page-link" data-page="${maxPage}"><c:out value="${maxPage}"/></a>
                    </li>
                </c:if>

                <c:if test="${navigationForm.pageNumber lt maxPage}">
                    <li class="page-item">
                            <%--suppress XmlDuplicatedId --%>
                        <a class="page-link" id="nextPage"><spring:message code="search.pagination.next"/></a>
                    </li>
                </c:if>
                <c:if test="${navigationForm.pageNumber ge maxPage}">
                    <li class="page-item disabled">
                            <%--suppress XmlDuplicatedId --%>
                        <a class="page-link" id="nextPage"><spring:message code="search.pagination.next"/></a>
                    </li>
                </c:if>
            </ul>
        </nav>
    </section>
</c:if>

<!-- TOAST -->
<div class="toast-container position-fixed bottom-0 end-0 p-3">
    <div id="liveToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
        <div class="toast-body justify-content-between d-flex">
            <span class="text-dark-primary"><spring:message code="toast.linkCopied"/></span>
            <button type="button" class="btn-close align-content-center" data-bs-dismiss="toast"
                    aria-label="Close"></button>
        </div>
    </div>
</div>

<!-- CREATE NOTE MODAL -->
<div class="modal fade" id="createNoteModal" data-bs-backdrop="static" data-bs-keyboard="false"
     tabindex="-1" aria-labelledby="uploadLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content box bg-bg">
            <div class="modal-header">
                <h1 class="modal-title fs-5" id="uploadLabel"><spring:message
                        code="uploadNote"/></h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal"
                        aria-label="Close">
                </button>
            </div>
            <form:form modelAttribute="createNoteForm"
                       action="${createUrl}"
                       method="post"
                       enctype="multipart/form-data"
                       autocomplete="off"
                       class="d-flex flex-column"
                       id="createNoteForm">
                <div class="modal-body pb-0">
                    <!-- CREATE NOTE FORM -->


                    <div class="d-flex flex-column gap-2">
                        <div class="input-group">
                            <label class="input-group-text" for="file"><spring:message
                                    code="file"/></label>
                            <form:input path="file" type="file" class="form-control" id="file"/>
                        </div>
                        <form:errors path="file" cssClass="text-danger" element="p"/>
                    </div>

                    <div class="d-flex flex-column gap-2 mt-4">
                        <div class="input-group">
                            <label class="input-group-text" for="name"><spring:message
                                    code="name"/></label>
                            <form:input path="name" type="text"
                                        aria-label="<spring:message code=\"form.upload.name\"/>"
                                        class="form-control" id="name"/>
                        </div>
                        <form:errors path="name" cssClass="text-danger" element="p"/>
                        <form:errors cssClass="text-danger" element="p"/> <!-- Global errors -->
                    </div>

                    <div class="d-flex flex-column gap-2 mt-4">
                        <div class="input-group">
                            <label class="input-group-text" for="categorySelect"><spring:message
                                    code="category"/></label>
                            <form:select path="category" class="form-select" id="categorySelect">
                                <form:option value="theory"><spring:message
                                        code="category.theory"/></form:option>
                                <form:option value="practice"><spring:message
                                        code="category.practice"/></form:option>
                                <form:option value="exam"><spring:message
                                        code="category.exam"/></form:option>
                                <form:option value="other"><spring:message
                                        code="category.other"/></form:option>
                            </form:select>
                        </div>
                        <form:errors path="category" cssClass="text-danger" element="p"/>
                    </div>

                    <div class="d-flex flex-column gap-2 mt-4">
                        <div class="input-group">
                            <label class="input-group-text" for="visible"><spring:message
                                    code="privacy"/></label>
                            <form:select path="visible" class="form-select" id="visible">
                                <form:option value="true"><spring:message
                                        code="public"/></form:option>
                                <form:option value="false"><spring:message
                                        code="private"/></form:option>
                            </form:select>
                        </div>
                        <form:errors path="visible" cssClass="text-danger" element="p"/>
                    </div>

                    <input type="hidden" name="parentId" value="${directory.id}"/>
                    <input type="hidden" name="createNote" value="createNote"/>
                </div>
                <div class="modal-footer mt-4">
                    <button type="button" class="btn rounded-box button-primary"
                            data-bs-dismiss="modal">
                        <spring:message code="close"/></button>
                    <input type="submit" class="btn rounded-box button-secondary" value="<spring:message
                                            code="upload"/>"/>
                </div>
            </form:form>
        </div>
    </div>
</div>


<!-- CREATE DIRECTORY MODAL -->
<div class="modal fade" id="createDirectoryModal" data-bs-backdrop="static" data-bs-keyboard="false"
     tabindex="-1" aria-labelledby="createLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content box bg-bg">
            <div class="modal-header">
                <h1 class="modal-title fs-5" id="createLabel"><spring:message
                        code="createDirectory"/></h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal"
                        aria-label="Close">
                </button>
            </div>
            <form:form modelAttribute="createDirectoryForm"
                       action="${createUrl}"
                       method="post"
                       enctype="multipart/form-data"
                       autocomplete="off"
                       class="d-flex flex-column"
                       id="createDirectoryForm">
                <div class="modal-body pb-0">

                    <div class="d-flex flex-column gap-2">
                        <div class="input-group">
                            <label class="input-group-text" for="name"><spring:message
                                    code="name"/></label>
                            <form:input path="name" type="text"
                                        aria-label="<spring:message code=\"form.upload.name\"/>"
                                        class="form-control" id="name"/>
                        </div>
                        <form:errors path="name" cssClass="text-danger" element="p"/>
                        <form:errors cssClass="text-danger" element="p"/> <!-- Global errors -->
                    </div>

                    <div class="d-flex flex-column gap-2 mt-4">
                        <div class="input-group">
                            <label class="input-group-text" for="visible"><spring:message
                                    code="privacy"/></label>
                            <form:select path="visible" class="form-select" id="visible">
                                <form:option value="true"><spring:message
                                        code="public"/></form:option>
                                <form:option value="false"><spring:message
                                        code="private"/></form:option>
                            </form:select>
                        </div>
                        <form:errors path="visible" cssClass="text-danger" element="p"/>
                    </div>

                    <div class="d-flex flex-column gap-2 mt-4">
                        <div class="input-group gap-3 d-flex align-items-center">
                            <label class="input-group-text"><spring:message
                                    code="color"/></label>
                            <c:forEach var="color" items="${colors}">
                                <div>
                                    <form:radiobutton path="color" value="${color}" id="color${color}"
                                                      cssClass="d-none color-radio"/>
                                    <img src="<c:url value="/svg/folder.svg"/>" alt="${folder}"
                                         class="color-option icon-m fill-${color} >"/>
                                </div>
                            </c:forEach>
                            <form:errors path="color" cssClass="text-danger" element="p"/>
                        </div>
                    </div>

                    <input type="hidden" name="parentId" value="${directory.id}"/>
                    <input type="hidden" name="createDirectory" value="createDirectory"/>
                </div>
                <div class="modal-footer mt-4">
                    <button type="button" class="btn rounded-box button-primary"
                            data-bs-dismiss="modal">
                        <spring:message code="close"/>
                    </button>
                    <input type="submit" class="btn rounded-box button-secondary" value="<spring:message
                                            code="upload"/>"/>
                </div>
            </form:form>
        </div>
    </div>
</div>


<c:url value="../notes/" var="editNoteUrl"/>
<c:url value="./${directoryId}" var="editDirectoryUrl"/>


<!--  EDIT NOTE MODAL -->
<div class="modal fade" id="editNoteModal" data-bs-backdrop="static" data-bs-keyboard="false"
     tabindex="-1" aria-labelledby="editNoteLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content box bg-bg">
            <div class="modal-header">
                <h1 class="modal-title fs-5" id="editNoteLabel"><spring:message
                        code="editNote"/></h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal"
                        aria-label="Close">
                </button>
            </div>
            <form:form modelAttribute="editNoteForm"
                       action="${editNoteUrl}"
                       method="post"
                       enctype="multipart/form-data"
                       autocomplete="off"
                       class="d-flex flex-column"
                       id="editNoteForm">
                <div class="modal-body pb-0">
                    <!-- EDIT NOTE FORM -->


                    <div class="d-flex flex-column gap-2">
                        <div class="input-group">
                            <label class="input-group-text" for="name"><spring:message
                                    code="name"/></label>
                            <form:input path="name" type="text"
                                        aria-label="<spring:message code=\"form.upload.name\"/>"
                                        class="form-control" id="name"/>
                        </div>
                        <form:errors path="name" cssClass="text-danger" element="p"/>
                        <form:errors cssClass="text-danger" element="p"/> <!-- Global errors -->
                    </div>

                    <div class="d-flex flex-column gap-2 mt-4">
                        <div class="input-group">
                            <label class="input-group-text" for="categorySelect"><spring:message
                                    code="category"/></label>
                            <form:select path="category" class="form-select" id="categorySelect">
                                <form:option value="theory"><spring:message code="category.theory"/></form:option>
                                <form:option value="practice"><spring:message
                                        code="category.practice"/></form:option>
                                <form:option value="exam"><spring:message code="category.exam"/></form:option>
                                <form:option value="other"><spring:message code="category.other"/></form:option>
                            </form:select>
                        </div>
                        <form:errors path="category" cssClass="text-danger" element="p"/>
                    </div>

                    <div class="d-flex flex-column gap-2 mt-4">
                        <div class="input-group">
                            <label class="input-group-text" for="visible"><spring:message
                                    code="privacy"/></label>
                            <form:select path="visible" class="form-select" id="visible">
                                <form:option value="true"><spring:message
                                        code="public"/></form:option>
                                <form:option value="false"><spring:message
                                        code="private"/></form:option>
                            </form:select>
                        </div>
                        <form:errors path="visible" cssClass="text-danger" element="p"/>
                    </div>
                </div>
                <div class="modal-footer mt-4">
                    <button type="button" class="btn rounded-box button-primary"
                            data-bs-dismiss="modal">
                        <spring:message code="close"/></button>
                    <input type="submit" class="btn rounded-box button-secondary" value="<spring:message
                                                code="update"/>"/>
                </div>
                <input type="hidden" id="noteId" name="id" value=""/>
                <input type="hidden" name="parentId" value="${directory.id}"/>
                <input type="hidden" name="redirectUrl" value="/directory/${directoryId}"/>
            </form:form>
        </div>
    </div>
</div>


<!-- EDIT DIRECTORY MODAL-->
<div class="modal fade" id="editDirectoryModal" data-bs-backdrop="static" data-bs-keyboard="false"
     tabindex="-1" aria-labelledby="editDirectoryLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content box bg-bg">
            <div class="modal-header">
                <h1 class="modal-title fs-5" id="editDirectoryLabel"><spring:message
                        code="editDirectory"/></h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal"
                        aria-label="Close">
                </button>
            </div>
            <form:form modelAttribute="editDirectoryForm"
                       action=""
                       method="post"
                       enctype="multipart/form-data"
                       autocomplete="off"
                       class="d-flex flex-column"
                       id="editDirectoryForm">
                <div class="modal-body pb-0">
                    <!-- EDIT DIRECTORY FORM -->


                    <div class="d-flex flex-column gap-2">
                        <div class="input-group">
                            <label class="input-group-text" for="name"><spring:message
                                    code="name"/></label>
                            <!-- TODO: change value JS-->
                            <form:input path="name" type="text"
                                        aria-label="<spring:message code=\"form.upload.name\"/>"
                                        class="form-control" id="name"/>
                        </div>
                        <form:errors path="name" cssClass="text-danger" element="p"/>
                        <form:errors cssClass="text-danger" element="p"/> <!-- Global errors -->
                    </div>

                    <div class="d-flex flex-column gap-2 mt-4">
                        <div class="input-group">
                            <label class="input-group-text" for="visible"><spring:message
                                    code="privacy"/></label>
                            <form:select path="visible" class="form-select" id="visible">
                                <form:option value="true"><spring:message
                                        code="public"/></form:option>
                                <form:option value="false"><spring:message
                                        code="private"/></form:option>
                            </form:select>
                        </div>
                        <form:errors path="visible" cssClass="text-danger" element="p"/>
                    </div>

                    <div class="d-flex flex-column gap-2 mt-4">
                        <div class="input-group gap-3 d-flex align-items-center">
                            <label class="input-group-text"><spring:message
                                    code="color"/></label>
                            <c:forEach var="color" items="${colors}">
                                <div>
                                    <form:radiobutton path="color" value="${color}" id="color${color}"
                                                      cssClass="d-none color-radio"/>
                                    <img src="<c:url value="/svg/folder.svg"/>" alt="${folder}"
                                         class="color-option icon-m fill-${color}"/>
                                </div>
                            </c:forEach>
                            <form:errors path="color" cssClass="text-danger" element="p"/>
                        </div>
                    </div>
                </div>

                <div class="modal-footer mt-4">
                    <button type="button" class="btn rounded-box button-primary"
                            data-bs-dismiss="modal">
                        <spring:message code="close"/></button>
                    <input type="submit" class="btn rounded-box button-secondary" value="<spring:message
                                                code="update"/>"/>
                </div>
                <input type="hidden" id="directoryId" name="id" value=""/>
                <input type="hidden" name="parentId" value="${directory.id}"/>
                <input type="hidden" name="redirectUrl" value="/directory/${directoryId}"/>
            </form:form>

        </div>
    </div>
</div>


<!-- DELETE MODAL -->
<c:url var="deleteUrl" value="./delete"/>
<div class="modal fade" id="deleteManyModal" data-bs-backdrop="static" data-bs-keyboard="false"
     tabindex="-1" aria-labelledby="deleteLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content box bg-bg">
            <div class="modal-header">
                <h1 class="modal-title fs-5" id="deleteLabel"><spring:message code="delete"/></h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal"
                        aria-label="Close">
                </button>
            </div>
            <form:form id="deleteForm" method="POST" action="${deleteUrl}">
                <div class="modal-body pb-0">
                    <spring:message code="DeleteForm.description"/>
                    <!-- DYNAMICALLY ADDED INPUTS -->
                </div>

                <div class="modal-footer mt-4">
                    <button type="button" class="btn rounded-box button-primary"
                            data-bs-dismiss="modal">
                        <spring:message code="close"/></button>
                    <input id="deleteSelectedButton" type="submit" class="btn rounded-box button-secondary" value="<spring:message
                                                code="delete"/>"/>
                </div>

                <input type="hidden" name="redirectUrl" value="/directory/${directoryId}"/>

            </form:form>
        </div>
    </div>
</div>


<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-HwwvtgBNo3bZJJLYd8oVXjrBZt8cqVSpeBNS5n7C8IVInixGAoxmnlMuBnhbgrkm"
        crossorigin="anonymous"></script>

<script src="<c:url value="/js/darkmode.js"/>"></script>
<%--<script src="<c:url value="/js/autocomplete.js"/>"></script>--%>
<script src="<c:url value="/js/ascdesc.js"/>"></script>
<script src="<c:url value="/js/popups.js"/>"></script>
<script src="<c:url value="/js/color-picker.js"/>"></script>
<c:if test="${not empty results}">
    <script src="<c:url value="/js/note-list.js"/>"></script>
    <script src="<c:url value="/js/search-buttons.js"/>"></script>
    <script src="<c:url value="/js/crud-buttons.js"/>"></script>
    <script src="<c:url value="/js/pagination.js"/>"></script>
</c:if>
<script src="<c:url value="/js/global-search.js"/>"></script>

<c:if test="${errorsEditNoteForm != null}">
    <script>
        const id = "<c:out value="${editNoteId}"/>";
        edit(id, true);
        let editNoteModal = new bootstrap.Modal(document.getElementById('editNoteModal'), {})
        editNoteModal.show();
    </script>
</c:if>

<c:if test="${errorsEditDirectoryForm != null}">
    <script>
        const id = "<c:out value="${editDirectoryId}"/>";
        edit(id, true);
        let editDirectoryModal = new bootstrap.Modal(document.getElementById('editDirectoryModal'), {})
        editDirectoryModal.show();
    </script>
</c:if>

<c:if test="${errorsCreateNoteForm != null}">
    <script>
        const createNoteModalButton = document.getElementById('createNoteModalButton');
        createNoteModalButton.click()
    </script>
</c:if>

<c:if test="${errorsCreateDirectoryForm != null}">
    <script>
        const createDirectoryModalButton = document.getElementById('createDirectoryModalButton');
        createDirectoryModalButton.click()
    </script>
</c:if>

</body>

</html>
