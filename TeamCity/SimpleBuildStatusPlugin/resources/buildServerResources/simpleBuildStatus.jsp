<%@ include file="../../include.jsp" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>SimpleBuildStatus - ${project.name}:${project.status}</title>
</head>
<body>

<c:choose>
    <c:when test="${project.status == 'NORMAL'}">
            <% response.sendError(200, "OK"); %>
    </c:when>
    <c:otherwise>
            <% response.sendError(409, "CONFLICT"); %>
    </c:otherwise>
</c:choose>

</body>
</html>