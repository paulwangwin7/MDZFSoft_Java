<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ include file="/common/taglibs.jsp"%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<%@ include file="/common/header.jsp"%>
<%@ include file="/plugins/jquery-nyroModal.jsp" %>
<%@ include file="/plugins/jquery-validation.jsp"%>
<%@ include file="/plugins/jquery-powerFloat.jsp" %>
<%@ include file="/plugins/ztree.jsp"%>
</head>
<body>
	<form:form id="addForm" name="addForm" method="POST" action="${ctx}/corpMgr/save" modelAttribute="resultObject">
		<form:hidden path="status"/>
		<form:hidden path="corpType"/>
			<div class="gray_bor_bg">
				<div class="table_div">
					<table width="100%" class="table_border">
						<tr>
							<td class="title" width="100"></td>
							<td align="left">
								带<font color="red">&nbsp;*&nbsp;</font>为必填项
							</td>
						</tr>
						<tr>
							<td class="title" width="100">
								<font color="red">*&nbsp;</font>部门名称
							</td>
							<td>
								<form:input path="corpName" cssClass="form_input {required:true,maxlength:20}" size="20" />
							</td>
						</tr>
						<tr>
							<td class="title" width="100">
								<font color="red">*&nbsp;</font>上级部门
							</td>
							<td>
								<form:hidden path="parentCorpId"/>
								<input type="text" name="parentCorpName"  id="parentCorpName" size="20" value="${resultObject.parentCorpName}" class="form_input {required:true}" readonly="readonly" style="cursor: pointer;"/>
								<div id="corpChooseDiv" style="position:absolute; border:solid 1px #CCCCCC; width:250px; height:200px; top:23px; left:0px; background:#FFFFFF;display: none;z-index:99;overflow:auto">
							         <ul id="treeDemo" class="ztree" style="width: 180px;">
							         </ul>
						        </div>
							</td>
						</tr>
						<tr>
							<td class="title" width="100">
								<font color="red">*&nbsp;</font>文件服务器
							</td>
							<td>
								<input type="hidden" name="sysFtp.ftpId" id="ftpId" value="${parent.sysFtp.ftpId}">
								<input type="text" size="20" value="${parent.sysFtp.serverName}" style="cursor: pointer;" onclick="showFtpSelectPage('FTP服务器选择','ftpId','ftpIp','ftpDesc')" class="form_input {required:true}" name="ftpIp" id="ftpIp">
								<br/><span id='ftpDesc' >${parent.sysFtp.ftpDesc}</span>
							</td>
						</tr>
						<tr>
							<td align="center" valign="middle" colspan="2">
								<input type="submit" value="提交" class="blue_mod_btn">
								<input type="button" value="取消" class="blue_mod_btn" onclick="parent.closeModalWindow();">
							</td>
						</tr>
					</table>
				</div>
			</div>
	</form:form>
</body>
	<a  id="modalWindowAction" class="nyroModal" href="#" target="_blank" style="display:none" title="选择FTP服务器">选择FTP服务器</a>
	<script>
	
	$(function(){
		//树形菜单
		var setting = {
			data: {
				simpleData: {enable: true}
			},
			callback: {
				onClick: onClick
			}
		};
		var zNodes = ${tree.json};  
		$(document).ready(function(){
			$.fn.zTree.init($("#treeDemo"), setting, zNodes);
		});
		
		$('#addForm').validate();
		
		$('#addForm').ajaxForm({
			 dataType:  'json',
		     success:   onSuccess
		});
		
		$('.nyroModal').nyroModal({});
	});
	$("#parentCorpName").powerFloat({
		eventType: "click",
		target: $("#corpChooseDiv")	
	});
	
	function onClick(e, treeId, treeNode) {
		var treeObj = $.fn.zTree.getZTreeObj("treeDemo");
		var nodes = treeObj.getSelectedNodes();
		var corpId = nodes[0].id;
		var corpName = nodes[0].name;
		$("#parentCorpName").val(corpName);
		$("#parentCorpId").val(corpId);
		$.powerFloat.hide();
		$("#corpChooseDiv").css("display","none");
	}
	function onSuccess(data) {
	    if(data.messageType=='1')
	    {
	    	alert(data.promptInfo);
	    	parent.closeModalWindow(true);
	    }
	    else
	    {
	    	alert(data.promptInfo);
	    }
	}
	
	function showFtpSelectPage(title,ftpId,ftpIp,ftpDesc)
	{	
		var url = '${ctx}/ftpMgr/ftpSelect?ftpId='+ftpId+'&ftpIp='+ftpIp+'&ftpDesc='+ftpDesc+'&r='+Math.random();
	  	$('#modalWindowAction').attr("href",url);
	  	$('#modalWindowAction').attr("title",title);
	  	$('#modalWindowAction').click();
	}
</script>
</html>