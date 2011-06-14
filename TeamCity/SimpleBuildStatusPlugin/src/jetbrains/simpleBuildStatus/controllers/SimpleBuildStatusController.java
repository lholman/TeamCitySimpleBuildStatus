package jetbrains.simpleBuildStatus.controllers;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jetbrains.buildServer.controllers.BaseController;
import jetbrains.buildServer.serverSide.ProjectManager;
import jetbrains.buildServer.serverSide.SProject;
import jetbrains.buildServer.serverSide.SBuildServer;
import jetbrains.buildServer.web.openapi.WebControllerManager;

import org.springframework.web.servlet.ModelAndView;

/**
 * Registers a Spring controllers to map /simpleBuildStatus.html to simpleBuildStatus.jsp
 */
public class SimpleBuildStatusController extends BaseController {
    public static final String PROJECT_NAME = "projectName";
    private final ProjectManager projectManager;
    private final WebControllerManager myManager;

    public SimpleBuildStatusController(SBuildServer sBuildServer,
                                       ProjectManager projectManager,
                                       WebControllerManager manager) {
        super(sBuildServer);
        this.projectManager = projectManager;
        this.myManager = manager;
    }

    /**
     * Main method which returns after user presses 'View simple build status' button or browses to http://teamcity.example.com/simpleBuildStatus.html
     *
     * @param request  http request
     * @param response http response
     * @return object containing model object and view
     * @throws Exception
     */
    protected ModelAndView doHandle(HttpServletRequest request, HttpServletResponse response) throws Exception {
        if (requestHasParameter(request, PROJECT_NAME))
           return getProject(request.getParameter(PROJECT_NAME), response);
        else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "no projectName specified");
            return null;
        }
    }

    private ModelAndView getProject(String projectName, HttpServletResponse response) throws Exception {
        SProject project = projectManager.findProjectByName(projectName);
        if (project == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "no project with name " + projectName);
            return null;
        }
        return new ModelAndView("/plugins/simpleBuildStatusPlugin/simpleBuildStatus.jsp")
                .addObject("project", project);
    }

    private boolean requestHasParameter(HttpServletRequest request, String parameterName) {
        return request.getParameterMap().containsKey(parameterName);
    }

    public void register() {
        myManager.registerController("/simpleBuildStatus.html", this);
    }

}
