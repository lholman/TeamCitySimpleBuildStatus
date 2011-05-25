<%@ include file="/include-internal.jsp" %>
SimpleBuildStatus
  <c:forEach items="${projectMap}" var="project">

    <table class="tcTable">
      <tr>
        <td colspan="3" class="tcTD_projectName">
          <div class="projectName">
            <bs:projectLink project="${project.key}"/>
          </div>
        </td>
      </tr>

      <c:forEach items="${project.value}" var="buildType">
        <jsp:useBean id="buildType" type="jetbrains.buildServer.serverSide.SBuildType"/>

        <tr>
          <td class="buildConfigurationName">
            <bs:buildTypeIcon buildType="${buildType}" ignorePause="true" simpleTitle="true"/>
            <bs:buildTypeLink buildType="${buildType}"/>
          </td>

          <c:set var="buildData" value="${buildType.lastChangesFinished}"/>
          <td class="buildNumberDate">
            <c:if test="${not empty buildData}">
              <div class="teamCityBuildNumber">build <bs:buildNumber buildData="${buildData}" withLink="true"/></div>
              <div class="teamCityDateTime"><bs:date value="${buildData.finishDate}"/></div>
            </c:if>
          </td>
          <td class="buildResults">
            <c:if test="${not empty buildData}">
              <div class="teamCityBuildResults">
                <c:if test="${buildData.artifactsExists}">
                  <bs:artefactsIcon/>
                  <bs:artefactsLink build="${buildData}" noPopup="true">artifacts</bs:artefactsLink>
                </c:if>
                <c:if test="${not buildData.artifactsExists}">
                  <bs:buildDataIcon buildData="${buildData}" simpleTitle="true"/>
                  <bs:resultsLink build="${buildData}" noPopup="true">results</bs:resultsLink>
                </c:if>
              </div>
            </c:if>
          </td>
        </tr>

      </c:forEach>
    </table>

</c:forEach>
