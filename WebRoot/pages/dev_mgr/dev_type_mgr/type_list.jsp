<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ include file="/common/taglibs.jsp"%>
<html>
<head>
<%@ include file="/common/header.jsp"%>
<%@ include file="/plugins/tablesorter.jsp"%>
<%@ include file="/plugins/jquery-nyroModal.jsp" %>
<%@ include file="/plugins/jquery-powerFloat.jsp" %>
<%@ include file="/plugins/ztree.jsp"%>
</head>
<body>
	<%@ include file="/pages/top.jsp"%>
	<form id="mainForm" action="${ctx}/devTypeMgr" method="post">
		<input type="hidden" name="pageNo" id="pageNo" value="${page.pageNo}" />
		<input type="hidden" name="pageSize" id="pageSize" value="${page.pageSize}" />
		<input type="hidden" name="orderBy" id="orderBy" value="${page.orderBy}" />
		<input type="hidden" name="order" id="order" value="${page.order}" />
		<div id="container">
			<div class="layout clearfix">
				<div class="white_p10">
					<h4 class="content_hd long_content_hd">设备类型</h4>
					<div class="content_bd">
						<div class="gray_bor_bg">
							<h5 class="gray_blod_word">按条件查询</h5>
							<div class="search_form">
								<div class="mt_10">
									<label>设备类型：</label>
									<input type="text" id="devTypeName" name="filter_LIKE_devTypeName" value="${param['filter_LIKE_devTypeName']}" class="input_79x19" />
							        &nbsp;&nbsp;&nbsp;&nbsp;
									<a href="javascript:$('#mainForm').submit()" class="blue_mod_btn">查&nbsp;询</a>
									<a href="javascript:clearForm()" class="blue_mod_btn">重&nbsp;置</a>
								</div>
							</div>
						</div>
						<div style="margin-top: 10px">
							<a href="${ctx}/devTypeMgr/add?r=<%=Math.random() %>" class="blue_mod_btn nyroModal" target="_blank" title="新增">新增</a>
						</div>
						<div class="mange_table log_table mt_10">
							<table id="tableList" cellspacing="1" class="tablesorter" width="100%">
								<thead>
									<tr align="center">
										<th>序号</th>
										<th>设备类型</th>
										<th>操作</th>
									</tr>
								</thead>
								<tbody>
									<c:if test="${page.totalCount != '0'}">
										<c:forEach var="devType" items="${page.result}" varStatus="status">
											<tr align="center">
												<td>${status.count}</td>
												<td>${devType.devTypeName}</td>
												<td>
													<a href="${ctx}/devTypeMgr/edit/${devType.devTypeId}?r=<%=Math.random() %>" class="nyroModal" target="_blank" title="修改"><img src="images/icons/edit.png" alt="修改" /></a>
													<a href="javascript:devTypeDelete('${devType.devTypeId}')" title="删除"><img src="images/icons/cross.png" alt="删除" /></a>
												</td>
											</tr>
										</c:forEach>
									</c:if>
									<c:if test="${page.totalCount == '0'}">
										<tr align="center">
											<td colspan="9" align="left">暂无符合条件的记录</td>
										</tr>
									</c:if>
								</tbody>
							</table>
						</div>
						<jsp:include page="/plugins/pager.jsp" flush="true" />
						<div class=" mt_10 pb_200"></div>
					</div>
				</div>
			</div>
		</div>
	</form>
	<%@ include file="/pages/footer.jsp"%>
</body>
<script type="text/javascript">
	$(function() {
		$('.nyroModal').nyroModal();
	});
	//页面加载初始化方法，实现查询条件下拉列表的回显功能
	function init()
	{
		$("#devTypeName").val("${param['filter_LIKE_devTypeName']}");
	}
	init();

	function query(){
		$("#pageNo").val("1");
		$("#pageSize").val("10");
		$("#mainForm").submit();
	}
	
	function clearForm(){
		$("#devTypeName").val("");
	}
	
	//删除
	function devTypeDelete(id)
	{
		if(confirm("您确认删除该类型吗？"))
		{
			$.getJSON("${ctx}/devTypeMgr/delete/"+id+"?r="+Math.random(), function(data){
				if(data.messageType=='1')
			    {
			    	alert(data.promptInfo);
			    	location.href = location.href;
			    }
			    else
			    {
			    	alert(data.promptInfo);
			    }
			});
		}
	}
	</script>
</html>