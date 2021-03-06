package com.njmd.zfms.web.controller;

import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.njmd.framework.commons.ResultInfo;
import com.njmd.framework.commons.Tree;
import com.njmd.framework.controller.BaseController;
import com.njmd.framework.dao.HibernateWebUtils;
import com.njmd.framework.dao.Page;
import com.njmd.framework.dao.PropertyFilter;
import com.njmd.framework.dao.PropertyFilter.MatchType;
import com.njmd.zfms.annotation.Permission;
import com.njmd.zfms.web.constants.RequestNameConstants;
import com.njmd.zfms.web.constants.ResultConstants;
import com.njmd.zfms.web.constants.UrlConstants;
import com.njmd.zfms.web.entity.sys.SysLogin;
import com.njmd.zfms.web.entity.sys.SysLoginRole;
import com.njmd.zfms.web.entity.sys.SysRole;
import com.njmd.zfms.web.service.SysLoginRoleService;
import com.njmd.zfms.web.service.SysPermissionService;
import com.njmd.zfms.web.service.SysRolePermissionService;
import com.njmd.zfms.web.service.SysRoleService;

@Controller
@RequestMapping("/roleMgr")
public class RoleMgrController extends BaseController
{

	private final String[] INFORMATION_PARAMAS = { "角色", "角色名称" };
	// 基础目录
	private final String BASE_DIR = "/sys_mgr/role_mgr/";

	private final String REDIRECT_PATH = "/roleMgr";

	@Autowired
	private SysRoleService sysRoleService;

	@Autowired
	private SysLoginRoleService sysLoginRoleService;

	@Autowired
	private SysRolePermissionService sysRolePermissionService;

	@Autowired
	private SysPermissionService sysPermissionService;

	/** 列表查询 */
	@RequestMapping
	@Permission(resource=Permission.Resources.SYSROLE,action=Permission.Actions.LIST)
	public String index(HttpServletRequest request, Page page, Model model) throws Exception
	{
		// 设置默认排序方式
		if (!page.isOrderBySetted())
		{
			page.setOrder(Page.DESC);
			page.setOrderBy("status");
		}
		List<PropertyFilter> filters = HibernateWebUtils.buildPropertyFilters(request);
		SysLogin sysLogin = this.getLoginToken().getSysLogin();
		if (sysLogin.getUserType().longValue() != SysLogin.USER_TYPE_SUPER_ADMIN)
		{
			if (sysLogin.getSysLoginRoles() != null)
			{
				for (SysLoginRole sysLoginRole : sysLogin.getSysLoginRoles())
				{
					SysRole sysRole = sysLoginRole.getSysRole();
					filters.add(new PropertyFilter("roleId", MatchType.NE, sysRole.getRoleId()));
				}
			}
		}
		Page pageResult = sysRoleService.query(page, filters);
		model.addAttribute(RequestNameConstants.PAGE_OBJECT, pageResult);
		return BASE_DIR + "role_list";
	}

	/** 进入新增 */
	@RequestMapping(value = "/add")
	@Permission(resource=Permission.Resources.SYSROLE,action=Permission.Actions.ADD)
	public String add(HttpServletRequest request, Model model) throws Exception
	{
		Tree tree = sysPermissionService.getMenuTree(request);
		model.addAttribute("tree", tree);
		model.addAttribute(RequestNameConstants.RESULT_OBJECT, new SysRole());
		return BASE_DIR + "role_add";
	}

	/** 保存新增 */
	@RequestMapping(value = "/save")
	@ResponseBody
	@Permission(resource=Permission.Resources.SYSROLE,action=Permission.Actions.ADD)
	public ResultInfo save(HttpServletRequest request, Model model, SysRole entity) throws Exception
	{
		try
		{
			int resultTag = sysRoleService.save(entity);
			savedObjectForLog(entity);
			if (resultTag == ResultConstants.SAVE_SUCCEED)
			{
				return ResultInfo.saveMessage(ResultConstants.getResultInfo(resultTag, INFORMATION_PARAMAS), REDIRECT_PATH);
			}
			else
			{
				model.addAttribute(RequestNameConstants.RESULT_OBJECT, entity);
				return ResultInfo.saveErrorMessage(ResultConstants.getResultInfo(resultTag, INFORMATION_PARAMAS));
			}
		}
		catch (Throwable t)
		{
			logger.error("角色保存异常", t);
			return ResultInfo.saveErrorMessage(ResultConstants.getResultInfo(ResultConstants.SYSTEM_ERROR, INFORMATION_PARAMAS));
		}

	}

	/** 删除 */
	@RequestMapping(value = "/delete/{id}")
	@ResponseBody
	@Permission(resource=Permission.Resources.SYSROLE,action=Permission.Actions.DELETE)
	public ResultInfo delete(HttpServletRequest request, Model model, @PathVariable("id") Long id) throws Exception
	{
		SysRole entity=sysRoleService.findById(id);
		int resultTag = sysRoleService.delete(id);
		if (resultTag == ResultConstants.DELETE_SUCCEED)
		{	savedObjectForLog(entity);
			return ResultInfo.saveMessage(ResultConstants.getResultInfo(resultTag, INFORMATION_PARAMAS), REDIRECT_PATH);
		}
		else
		{
			return ResultInfo.saveErrorMessage(ResultConstants.getResultInfo(resultTag, INFORMATION_PARAMAS));
		}
	}

	/** 批量删除 */
	@RequestMapping(value = "/batchDelete")
	@Permission(resource=Permission.Resources.SYSROLE,action=Permission.Actions.BATCHDELETE)
	public String batchDelete(HttpServletRequest request, Model model, Long[] id) throws Exception
	{

		int resultTag = sysRoleService.delete(id);
		if (resultTag == ResultConstants.DELETE_SUCCEED)
		{
			ResultInfo.saveMessage(ResultConstants.getResultInfo(resultTag, INFORMATION_PARAMAS), request, REDIRECT_PATH);
		}
		else
		{
			ResultInfo.saveErrorMessage(ResultConstants.getResultInfo(resultTag, INFORMATION_PARAMAS), request);
		}

		return UrlConstants.INFORMATION_PAGE;
	}

	/** 进入编辑 */
	@RequestMapping(value = "/edit/{id}")
	@Permission(resource=Permission.Resources.SYSROLE,action=Permission.Actions.UPDATE)
	public String edit(HttpServletRequest request, Model model, @PathVariable("id") Long id) throws Exception
	{

		SysRole entity = sysRoleService.findById(id);
		String rolePermissIds = sysRolePermissionService.findPermissionIdsByRoleIds(id);
		Tree tree = sysPermissionService.getMenuTree(request);
		
		savedObjectForLog(entity);
		model.addAttribute("rolePermissIds", rolePermissIds);
		model.addAttribute("tree", tree);
		model.addAttribute(RequestNameConstants.RESULT_OBJECT, entity);

		return BASE_DIR + "role_edit";
	}

	/** 修改保存 */
	@RequestMapping(value = "/update")
	@ResponseBody
	@Permission(resource=Permission.Resources.SYSROLE,action=Permission.Actions.UPDATE)
	public ResultInfo update(HttpServletRequest request, Model model, SysRole entity) throws Exception
	{
		try
		{
			int resultTag = sysRoleService.update(entity);
			savedObjectForLog(entity);
			if (resultTag == ResultConstants.UPDATE_SUCCEED)
			{
				return ResultInfo.saveMessage(ResultConstants.getResultInfo(resultTag, INFORMATION_PARAMAS), REDIRECT_PATH);
			}
			else
			{
				return ResultInfo.saveErrorMessage(ResultConstants.getResultInfo(resultTag, INFORMATION_PARAMAS));
			}
		}
		catch (Throwable t)
		{
			logger.error("角色修改异常", t);
			return ResultInfo.saveErrorMessage(ResultConstants.getResultInfo(ResultConstants.SYSTEM_ERROR, INFORMATION_PARAMAS));
		}

	}
}
