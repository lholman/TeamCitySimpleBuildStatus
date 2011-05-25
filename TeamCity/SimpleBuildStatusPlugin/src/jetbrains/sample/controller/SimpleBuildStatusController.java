package jetbrains.sample.controller;

import jetbrains.buildServer.controllers.BaseController;
import jetbrains.buildServer.serverSide.ProjectManager;
import jetbrains.buildServer.serverSide.SBuildServer;
import jetbrains.buildServer.serverSide.SBuildType;
import jetbrains.buildServer.serverSide.SProject;
import jetbrains.buildServer.users.SUser;
import jetbrains.buildServer.web.openapi.WebControllerManager;
import jetbrains.buildServer.web.util.SessionUser;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.HashMap;

/**
 * Our sample controller
 */
public class SimpleBuildStatusController extends BaseController {
    private final ProjectManager projectManager;
    private final WebControllerManager myManager;

    public SimpleBuildStatusController(SBuildServer sBuildServer, ProjectManager projectManager, WebControllerManager manager) {
        super(sBuildServer);
        this.projectManager = projectManager;
        this.myManager = manager;
    }

    /**
     * Main method which works after user presses 'View simple build status' button or browses to http://teamcity.example.com/simpleBuildStatus.html
     *
     * @param httpServletRequest  http request
     * @param httpServletResponse http response
     * @return object containing model object and view (page aggress)
     * @throws Exception
     */
    protected ModelAndView doHandle(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {
        SUser user = SessionUser.getUser(httpServletRequest);
        HashMap params = new HashMap();
        params.put("userName", user.getDescriptiveName());
        return new ModelAndView("/plugins/simpleBuildStatusPlugin/simpleBuildStatus.jsp", params);
    }

    public void register() {
        myManager.registerController("/simpleBuildStatus.html", this);
    }

}
