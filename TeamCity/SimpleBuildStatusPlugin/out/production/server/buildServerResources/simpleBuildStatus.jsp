<%@ include file="../../include.jsp" %>
<html>
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