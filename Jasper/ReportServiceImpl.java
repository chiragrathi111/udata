package com.pipra.stonex.service.impl;

import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.stream.Collectors;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import javax.imageio.ImageIO;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;

import org.codehaus.jettison.json.JSONArray;
import org.codehaus.jettison.json.JSONObject;
import org.compiere.model.MAttachment;
import org.compiere.model.MAttachmentEntry;
import org.compiere.model.MSysConfig;
import org.compiere.model.MUser;
import org.compiere.model.PO;
import org.compiere.model.Query;
import org.compiere.model.X_AD_Client;
import org.compiere.model.X_AD_Org;
import org.compiere.util.Env;
import org.compiere.util.KeyNamePair;
import org.compiere.util.Login;

import com.itextpdf.text.Document;
import com.itextpdf.text.Image;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfPTable;
import com.pipra.stonex.entity.X_pi_project;
import com.pipra.stonex.entity.X_pi_report_subtask;
import com.pipra.stonex.entity.X_pi_report_subtask_field;
import com.pipra.stonex.entity.X_pi_report_task;
import com.pipra.stonex.entity.X_pi_subtask_field;
import com.pipra.stonex.entity.model.AdClient_custom;
import com.pipra.stonex.entity.model.AdRole_Custom;
import com.pipra.stonex.entity.model.PI_Org_ReportConfig;
import com.pipra.stonex.entity.model.PI_Project;
import com.pipra.stonex.entity.model.PI_Report;
import com.pipra.stonex.entity.model.PI_SubTask;
import com.pipra.stonex.entity.model.PI_Task;
import com.pipra.stonex.model.response.Report;
import com.pipra.stonex.model.response.ReportOrgConfig;
import com.pipra.stonex.model.response.ReportSubTask;
import com.pipra.stonex.model.response.ReportSubTaskField;
import com.pipra.stonex.model.response.ReportSubtaskInspection;
import com.pipra.stonex.model.response.ReportTask;
import com.pipra.stonex.service.ReportService;
import com.pipra.stonex.util.ErrorBuilder;
import com.pipra.stonex.util.StandardResponse;

import net.sf.jasperreports.engine.JRDataSource;
import net.sf.jasperreports.engine.JasperCompileManager;
import net.sf.jasperreports.engine.JasperExportManager;
import net.sf.jasperreports.engine.JasperFillManager;
import net.sf.jasperreports.engine.JasperPrint;
import net.sf.jasperreports.engine.JasperReport;
import net.sf.jasperreports.engine.data.JRBeanCollectionDataSource;

/**
 * ReportServiceImpl class
 * 
 * @author Mahendhar Reddy
 *
 */

public class ReportServiceImpl implements ReportService {

	private @Context HttpServletRequest request = null;

	public ReportServiceImpl() {
	}

	@Override
	public Response reportList(int limit, int offset, String searchKey) {
		Properties ctx = Env.getCtx();
		String trxName = null;

		int clientId = Env.getAD_Client_ID(ctx);
		int orgId = Env.getAD_Org_ID(ctx);
		int roleId = Env.getAD_Role_ID(ctx);
		int userId = Env.getAD_User_ID(ctx);

		AdClient_custom adClient = new AdClient_custom(ctx, clientId, trxName);

		AdRole_Custom role = new AdRole_Custom(ctx, roleId, trxName);
		if (!adClient.isSingleuser() && (!role.isAdministrator() && !role.isProjectManager()
				&& !role.isInspectioncontroller() && !role.isDocumentController())) {
			return Response.status(Status.NOT_FOUND).entity(
					new ErrorBuilder().status(Status.NOT_FOUND).title("User Dont have API Acess").build().toString())
					.build();
		}

		List<Integer> orgList = new ArrayList<>();
		Login login = new Login(ctx);
		KeyNamePair[] orgs = login.getOrgs(new KeyNamePair(roleId, ""));
		if (orgs != null) {
			for (KeyNamePair org : orgs) {
				orgList.add(Integer.valueOf(org.getID()));
			}
		}
		String orgIds = orgList.stream().map(Object::toString).collect(Collectors.joining(", "));

		List<PO> poList = PI_Report.getReportList(ctx, trxName, orgIds, searchKey, limit, offset, userId, role,
				adClient);

		List<Report> reportResponse = new ArrayList<>();
		if (poList == null || poList.size() == 0) {
			return Response.status(Status.NOT_FOUND)
					.entity(new ErrorBuilder().status(Status.NOT_FOUND).title("No Report found").build().toString())
					.build();
		}
		for (PO po : poList) {
			PI_Report report = new PI_Report(ctx, po.get_ID(), trxName);
			Report res = new Report();
			res.setActive(true);

			X_AD_Client client = new X_AD_Client(ctx, clientId, trxName);
			res.setClientName(client.getName());

			X_AD_Org org = new X_AD_Org(ctx, orgId, trxName);
			res.setOrgName(org.getName());

			MUser created = new MUser(ctx, report.getCreatedBy(), trxName);
			res.setCreated(report.getCreated());
			res.setCreatedBy(created.getName());

			MUser updated = new MUser(ctx, report.getUpdatedBy(), trxName);
			res.setUpdated(report.getUpdated());
			res.setUpdatedBy(updated.getName());

			res.setDescription(report.getDescription());
			res.setReportTitle(report.getreporttitle());
			res.setProjectTitle(report.getprojecttitle());
			res.setThemeColour(report.getthemecolour());
			res.setPiReportID(report.get_ID());

			reportResponse.add(res);
		}
		return Response.ok(reportResponse).build();
	}

	@Override
	public Response getReportById(int reportId) {
		Properties ctx = Env.getCtx();
		String trxName = null;

		int orgId = Env.getAD_Org_ID(ctx);

		int roleId = Env.getAD_Role_ID(ctx);
		int clientId = Env.getAD_Client_ID(ctx);
		AdClient_custom adClient = new AdClient_custom(ctx, clientId, trxName);

		AdRole_Custom role = new AdRole_Custom(ctx, roleId, trxName);
		if (!adClient.isSingleuser() && (!role.isAdministrator() && !role.isProjectManager()
				&& !role.isInspectioncontroller() && !role.isDocumentController())) {
			return Response.status(Status.NOT_FOUND).entity(
					new ErrorBuilder().status(Status.NOT_FOUND).title("User Dont have API Acess").build().toString())
					.build();
		}

		PI_Report report = new PI_Report(ctx, reportId, trxName);

		if (report == null || report.get_ID() == 0)
			return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity("Invalid Report").build();

		Report res = getReportDetail(reportId, ctx, trxName, orgId, clientId);
		return Response.ok(res).build();
	}

	private Report getReportDetail(int reportId, Properties ctx, String trxName, int orgId, int clientId) {
		PI_Report report = new PI_Report(ctx, reportId, trxName);
		Report res = new Report();

		MAttachment attachment = report.getAttachment();
		int count = -1;
		if (attachment != null && attachment.get_ID() != 0)
			count = attachment.getEntryCount();
		res.setFileCount(count);

		List<X_pi_report_task> reportTasks = PI_Report.getTasksforReport(reportId, ctx, trxName);
		List<ReportTask> taskResponse = new ArrayList<>();

		for (X_pi_report_task piTask : reportTasks) {

			ReportTask reportTask = new ReportTask();

			List<X_pi_report_subtask> reportSubTasks = PI_Report.getSubTasksforTask(piTask.get_ID(), ctx, trxName);
			List<ReportSubTask> subTaskList = new ArrayList<>();

			for (X_pi_report_subtask pi_SubTask : reportSubTasks) {

				ReportSubTask subTask = new ReportSubTask();
				subTask.setTableId(pi_SubTask.get_Table_ID());
				subTask.setArea(pi_SubTask.getarea());
				subTask.setDescription(pi_SubTask.getDescription());
				subTask.setName(pi_SubTask.getName());
				subTask.setPiReportTaskID(piTask.get_ID());
				subTask.setPiReportSubTaskID(pi_SubTask.get_ID());
				subTask.setStatus(pi_SubTask.getStatus());
				subTask.setPriority(pi_SubTask.getPriority());
				subTask.setTags(pi_SubTask.gettags());
				subTask.setChecked(pi_SubTask.isChecked());

				attachment = pi_SubTask.getAttachment();
				count = -1;
				if (attachment != null && attachment.get_ID() != 0)
					count = attachment.getEntryCount();
				subTask.setFileCount(count);

				List<X_pi_report_subtask_field> fieldList = PI_Report.getFieldsforSubTask(pi_SubTask.get_ID(), ctx,
						trxName);

				LinkedHashMap<Integer, List<X_pi_report_subtask_field>> list = new LinkedHashMap<>();

				for (X_pi_report_subtask_field po : fieldList) {

					if (!validateField(po.getName(), po.getconfig(), po.get_ID(), ctx))
						continue;

					int inspection = po.getInspection();

					list.computeIfAbsent(inspection, k -> new ArrayList<>()).add(po);
				}

				LinkedHashMap<Integer, List<X_pi_report_subtask_field>> sortedMap = list.entrySet().stream()
						.sorted(Map.Entry.comparingByKey()).collect(Collectors.toMap(Map.Entry::getKey,
								Map.Entry::getValue, (oldVal, newVal) -> oldVal, LinkedHashMap::new));

				List<ReportSubtaskInspection> inspectionList = new ArrayList<ReportSubtaskInspection>();
				for (Integer key : sortedMap.keySet()) {
					List<X_pi_report_subtask_field> sfList = sortedMap.get(key);
					ReportSubtaskInspection inspection = new ReportSubtaskInspection();
					inspection.setInspection(key);

					List<ReportSubTaskField> fields = new ArrayList<ReportSubTaskField>();
					for (X_pi_report_subtask_field pi_report_subtask_field : sfList) {

//						if (!validateField(pi_report_subtask_field.getName(), pi_report_subtask_field.getconfig(), pi_report_subtask_field.get_ID(), ctx))
//							continue;

						ReportSubTaskField field = new ReportSubTaskField();
						field.setTableId(pi_report_subtask_field.get_Table_ID());
						field.setConfig(pi_report_subtask_field.getconfig());
						field.setDescription(pi_report_subtask_field.getDescription());
						field.setHelptext(pi_report_subtask_field.gethelptext());
						field.setLabelname(pi_report_subtask_field.getlabelname());
						field.setName(pi_report_subtask_field.getName());
						field.setPiReportSubTaskFieldID(pi_report_subtask_field.get_ID());
						field.setPiReportSubTaskID(pi_report_subtask_field.getpi_report_subtask_ID());
						field.setRequired(pi_report_subtask_field.isrequired());
						field.setStepName(pi_report_subtask_field.getstepname());
						field.setStepNo(pi_report_subtask_field.getstepno());
						field.setChecked(pi_report_subtask_field.isChecked());
						field.setSequence(pi_report_subtask_field.getSequence());
						field.setComments(pi_report_subtask_field.getComments());

						attachment = pi_report_subtask_field.getAttachment();
						count = -1;
						if (attachment != null && attachment.get_ID() != 0)
							count = attachment.getEntryCount();
						field.setFileCount(count);

						fields.add(field);

					}
					inspection.setFields(fields);
					inspectionList.add(inspection);
				}

				subTask.setInspections(inspectionList);
				subTaskList.add(subTask);
			}
			reportTask.setSubTasks(subTaskList);

			reportTask.setDescription(piTask.getDescription());
			reportTask.setName(piTask.getName());
			reportTask.setPiReportTaskID(piTask.get_ID());
			reportTask.setStatus(piTask.getStatus());
			reportTask.setArea(piTask.getarea());
			reportTask.setPriority(piTask.getPriority());
			reportTask.setTags(piTask.gettags());
			reportTask.setTableId(piTask.get_Table_ID());
			reportTask.setPiReportID(reportId);
			reportTask.setChecked(piTask.isChecked());

			attachment = piTask.getAttachment();
			count = -1;
			if (attachment != null && attachment.get_ID() != 0)
				count = attachment.getEntryCount();
			reportTask.setFileCount(count);

			taskResponse.add(reportTask);
		}
		res.setTasks(taskResponse);

		res.setActive(true);

		X_AD_Client client = new X_AD_Client(ctx, clientId, trxName);
		res.setClientName(client.getName());

		X_AD_Org org = new X_AD_Org(ctx, orgId, trxName);
		res.setOrgName(org.getName());

		MUser created = new MUser(ctx, report.getCreatedBy(), trxName);
		res.setCreated(report.getCreated());
		res.setCreatedBy(created.getName());

		MUser updated = new MUser(ctx, report.getUpdatedBy(), trxName);
		res.setUpdated(report.getUpdated());
		res.setUpdatedBy(updated.getName());

		res.setDescription(report.getDescription());
		res.setReportTitle(report.getreporttitle());
		res.setProjectTitle(report.getprojecttitle());
		res.setThemeColour(report.getthemecolour());
		res.setPiReportID(report.get_ID());
		res.setTableId(report.get_Table_ID());
		res.setClientName(report.getClientName());
		res.setAddress(report.getAddress());
		res.setStatus(report.getStatus());
		res.setPiProjectID(report.getpi_report_ID());

		return res;
	}

	@Override
	public Response createReport(Report request) {
		Properties ctx = Env.getCtx();
		String trxName = null;

		int roleId = Env.getAD_Role_ID(ctx);
		int clientId = Env.getAD_Client_ID(ctx);
		AdClient_custom adClient = new AdClient_custom(ctx, clientId, trxName);

		AdRole_Custom role = new AdRole_Custom(ctx, roleId, trxName);
		if (!adClient.isSingleuser() && (!role.isAdministrator() && !role.isProjectManager()
				&& !role.isInspectioncontroller() && !role.isDocumentController())) {
			return Response.status(Status.NOT_FOUND).entity(
					new ErrorBuilder().status(Status.NOT_FOUND).title("User Dont have API Acess").build().toString())
					.build();
		}

		int projectId = request.getPiProjectID();

		PI_Project project = new PI_Project(ctx, projectId, trxName);
		if (project == null || project.get_ID() == 0)
			return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity("Invalid Project").build();

		PI_Report report = new PI_Report(ctx, 0, trxName);

		report.setDescription(request.getDescription());
		report.setreporttitle(request.getReportTitle());
		report.setprojecttitle(request.getProjectTitle());
		report.setthemecolour(request.getThemeColour());
		report.setDescription(request.getDescription());
		report.setpi_project_ID(projectId);
		report.setClientName(project.getClientName());
		report.setAddress(project.getAddress());
		report.setStatus("Created");

		if (!report.save(trxName)) {
			return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity("Failed to create Report").build();
		}

		MAttachment attachment = project.getAttachment();
		if (attachment != null && attachment.get_ID() != 0) {
			MAttachmentEntry[] entries = attachment.getEntries();
			if (entries != null && entries.length != 0) {
				for (MAttachmentEntry entry : entries) {
					MAttachment att = new MAttachment(ctx, report.get_Table_ID(), report.get_ID(), trxName);
					att.addEntry(entry);
					att.saveEx();
				}
			}
		}

		List<PO> poList = PI_Task.getTaskListByProject(ctx, trxName, projectId, clientId);
		if (poList != null && poList.size() != 0)

			for (PO po : poList) {

				PI_Task piTask = new PI_Task(ctx, po.get_ID(), trxName);

				X_pi_report_task pi_report_task = new X_pi_report_task(ctx, 0, trxName);
				pi_report_task.setDescription(piTask.getDescription());
				pi_report_task.setName(piTask.getName());
				pi_report_task.setStatus(piTask.getStatus());
				pi_report_task.setarea(piTask.getarea());
				pi_report_task.setPriority(piTask.getPriority());
				pi_report_task.settags(piTask.gettags());
				pi_report_task.setpi_report_ID(report.get_ID());
				pi_report_task.setStatus("Created");

				if (!pi_report_task.save(trxName)) {
					return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity("Failed to create Report")
							.build();
				}

				attachment = piTask.getAttachment();
				if (attachment != null && attachment.get_ID() != 0) {
					MAttachmentEntry[] entries = attachment.getEntries();
					if (entries != null && entries.length != 0) {
						for (MAttachmentEntry entry : entries) {
							MAttachment att = new MAttachment(ctx, pi_report_task.get_Table_ID(),
									pi_report_task.get_ID(), trxName);
							att.addEntry(entry);
							att.saveEx();
						}
					}
				}

				List<PO> subtaskPoList = PI_SubTask.getSubTasksForTask(ctx, trxName, po.get_ID(), 0);
				if (subtaskPoList != null && subtaskPoList.size() != 0)

					for (PO subtaskPo : subtaskPoList) {
						PI_SubTask pi_SubTask = new PI_SubTask(ctx, subtaskPo.get_ID(), trxName);

						X_pi_report_subtask pi_report_subtask = new X_pi_report_subtask(ctx, 0, trxName);
						pi_report_subtask.setDescription(pi_SubTask.getDescription());
						pi_report_subtask.setName(pi_SubTask.getName());
						pi_report_subtask.setStatus(pi_SubTask.getStatus());
						pi_report_subtask.setarea(pi_SubTask.getarea());
						pi_report_subtask.setPriority(pi_SubTask.getPriority());
						pi_report_subtask.settags(pi_SubTask.gettags());
						pi_report_subtask.setpi_report_task_ID(pi_report_task.get_ID());
						pi_report_subtask.setStatus("Created");

						if (!pi_report_subtask.save(trxName)) {
							return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
									.entity("Failed to create Report").build();
						}

						attachment = pi_SubTask.getAttachment();
						if (attachment != null && attachment.get_ID() != 0) {
							MAttachmentEntry[] entries = attachment.getEntries();
							if (entries != null && entries.length != 0) {
								for (MAttachmentEntry entry : entries) {
									MAttachment att = new MAttachment(ctx, pi_report_subtask.get_Table_ID(),
											pi_report_subtask.get_ID(), trxName);
									att.addEntry(entry);
									att.saveEx();
								}
							}
						}

						List<X_pi_subtask_field> fieldList = PI_SubTask.getSubTasksFields(ctx, trxName,
								pi_SubTask.get_ID());// subTask.get_ID());
						for (X_pi_subtask_field x_pi_subtask_field : fieldList) {

							X_pi_report_subtask_field pi_report_subtask_field = new X_pi_report_subtask_field(ctx, 0,
									trxName);
							pi_report_subtask_field.setDescription(x_pi_subtask_field.getDescription());
							pi_report_subtask_field.setName(x_pi_subtask_field.getName());
							pi_report_subtask_field.setconfig(x_pi_subtask_field.getconfig());
							pi_report_subtask_field.sethelptext(x_pi_subtask_field.gethelptext());
							pi_report_subtask_field.setlabelname(x_pi_subtask_field.getlabelname());
							pi_report_subtask_field.setpi_report_subtask_ID(pi_report_subtask.get_ID());
							pi_report_subtask_field.setstepname(x_pi_subtask_field.getstepname());
							pi_report_subtask_field.setstepno(x_pi_subtask_field.getstepno());
							pi_report_subtask_field.setisrequired(x_pi_subtask_field.isrequired());
							pi_report_subtask_field.setInspection(x_pi_subtask_field.getInspection());
							pi_report_subtask_field.setSequence(x_pi_subtask_field.getSequence());
							pi_report_subtask_field.setComments(x_pi_subtask_field.getComments());
							pi_report_subtask_field.saveEx();

							attachment = x_pi_subtask_field.getAttachment();
							if (attachment != null && attachment.get_ID() != 0) {
								MAttachmentEntry[] entries = attachment.getEntries();
								if (entries != null && entries.length != 0) {
									for (MAttachmentEntry entry : entries) {
										MAttachment att = new MAttachment(ctx, pi_report_subtask_field.get_Table_ID(),
												pi_report_subtask_field.get_ID(), trxName);
										att.addEntry(entry);
										att.saveEx();
									}
								}
							}
						}
					}

			}

		return getReportById(report.get_ID());
	}

//	@Override
//	public Response updateReport(Report request) {
//		Properties ctx = Env.getCtx();
//		String trxName = null;
//
//		PI_Report report = new PI_Report(ctx, request.getPiReportID(), trxName);
//		if (report.get_ID() == 0) {
//			return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity("Invalid Report").build();
//		}
//
//		int reportId = request.getPiReportID();
//		List<Integer> existingTaskIdList = new ArrayList<Integer>();
//		List<Integer> existingSubTaskIdList = new ArrayList<Integer>();
//		List<Integer> existingSubTaskFieldIdList = new ArrayList<Integer>();
//
//		List<X_pi_report_task> reportTasks = PI_Report.getTasksforReport(reportId, ctx, trxName);
//		reportTasks.forEach(task -> {
//			existingTaskIdList.add(task.get_ID());
//
//			List<X_pi_report_subtask> reportSubTasks = PI_Report.getSubTasksforTask(task.get_ID(), ctx, trxName);
//			reportSubTasks.forEach(subTask -> {
//				existingSubTaskIdList.add(subTask.get_ID());
//
//				List<X_pi_report_subtask_field> fieldList = PI_Report.getFieldsforSubTask(subTask.get_ID(), ctx,
//						trxName);
//				fieldList.forEach(subTaskField -> {
//					existingSubTaskFieldIdList.add(subTaskField.get_ID());
//				});
//
//			});
//
//		});
//
//		for (ReportTask task : request.getTasks()) {
//
//			X_pi_report_task pi_report_task = new X_pi_report_task(ctx, task.getPiReportTaskID(), trxName);
//			int taskId = task.getPiReportTaskID();
//			int indexToRemove = existingTaskIdList.indexOf(taskId);
//
//			if (existingTaskIdList.contains(taskId))
//				existingTaskIdList.remove(indexToRemove);
//			else {
//				pi_report_task.setDescription(task.getDescription());
//				pi_report_task.setName(task.getName());
//				pi_report_task.setStatus(task.getStatus());
//				pi_report_task.setarea(task.getArea());
//				pi_report_task.setPriority(task.getPriority());
//				pi_report_task.settags(task.getTags());
//				pi_report_task.setpi_report_ID(report.get_ID());
//
//				if (!pi_report_task.save(trxName)) {
//					return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity("Failed to create Report")
//							.build();
//				}
//			}
//
//			for (ReportSubTask subtask : task.getSubTasks()) {
//				int subTaskId = subtask.getPiReportSubTaskID();
//				int index = existingSubTaskIdList.indexOf(subTaskId);
//				if (existingSubTaskIdList.contains(subTaskId))
//					existingSubTaskIdList.remove(index);
//				else {
//
//					X_pi_report_subtask pi_report_subtask = new X_pi_report_subtask(ctx, 0, trxName);
//					pi_report_subtask.setDescription(subtask.getDescription());
//					pi_report_subtask.setName(subtask.getName());
//					pi_report_subtask.setStatus(subtask.getStatus());
//					pi_report_subtask.setarea(subtask.getArea());
//					pi_report_subtask.setPriority(subtask.getPriority());
//					pi_report_subtask.settags(subtask.getTags());
//					pi_report_subtask.setpi_report_subtask_ID(pi_report_task.get_ID());
//
//					if (!pi_report_subtask.save(trxName)) {
//						return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity("Failed to create Report")
//								.build();
//					}
//
//					subtask.setPiReportSubTaskID(pi_report_subtask.get_ID());
//				}
//
//				List<ReportSubtaskInspection> inspectionsList = subtask.getInspections();
//				if (inspectionsList != null)
//					for (ReportSubtaskInspection inspection : inspectionsList) {
//
//						List<ReportSubTaskField> fields = inspection.getFields();
//						for (ReportSubTaskField field : fields) {
//							int fieldId = field.getPiReportSubTaskFieldID();
//							int fieldIndex = existingSubTaskFieldIdList.indexOf(fieldId);
//							if (existingSubTaskFieldIdList.contains(fieldId))
//								existingSubTaskFieldIdList.remove(fieldIndex);
//							else {
//
//								X_pi_report_subtask_field pi_report_subtask_field = new X_pi_report_subtask_field(ctx,
//										0, trxName);
//								pi_report_subtask_field.setDescription(field.getDescription());
//								pi_report_subtask_field.setName(field.getName());
//								pi_report_subtask_field.setconfig(field.getConfig());
//								pi_report_subtask_field.sethelptext(field.getHelptext());
//								pi_report_subtask_field.setlabelname(field.getLabelname());
//								pi_report_subtask_field.setpi_report_subtask_ID(subtask.getPiReportSubTaskID());
//								pi_report_subtask_field.setstepname(field.getStepName());
//								pi_report_subtask_field.setstepno(field.getStepNo());
//								pi_report_subtask_field.setisrequired(field.isRequired());
//								pi_report_subtask_field.setInspection(inspection.getInspection());
//								pi_report_subtask_field.saveEx();
//							}
//						}
//					}
//			}
//
//		}
//
//		existingSubTaskFieldIdList.forEach(id -> {
//			try {
//				new X_pi_report_subtask_field(ctx, id, trxName).deleteEx(true);
//			} catch (Exception e) {
//
//			}
//		});
//
//		existingSubTaskIdList.forEach(id -> {
//			try {
//				new X_pi_report_subtask(ctx, id, trxName).deleteEx(true);
//			} catch (Exception e) {
//
//			}
//		});
//
//		existingTaskIdList.forEach(id -> {
//			try {
//				new X_pi_report_task(ctx, id, trxName).deleteEx(true);
//			} catch (Exception e) {
//
//			}
//		});
//
//		return getReportById(report.get_ID());
//	}

//	@Override
//	public Response updateReport(Report request) {
//		Properties ctx = Env.getCtx();
//		String trxName = null;
//
//		int roleId = Env.getAD_Role_ID(ctx);
//		int clientId = Env.getAD_Client_ID(ctx);
//		AdClient_custom adClient = new AdClient_custom(ctx, clientId, trxName);
//
//		AdRole_Custom role = new AdRole_Custom(ctx, roleId, trxName);
//		if (!adClient.isSingleuser() && (!role.isAdministrator() && !role.isProjectManager()
//				&& !role.isInspectioncontroller() && !role.isDocumentController())) {
//			return Response.status(Status.NOT_FOUND).entity(
//					new ErrorBuilder().status(Status.NOT_FOUND).title("User Dont have API Acess").build().toString())
//					.build();
//		}
//
//		PI_Report report = new PI_Report(ctx, request.getPiReportID(), trxName);
//		if (report.get_ID() == 0) {
//			return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity("Invalid Report").build();
//		}
//
//		int reportId = request.getPiReportID();
//		List<Integer> existingTaskIdList = new ArrayList<Integer>();
//		List<Integer> existingSubTaskIdList = new ArrayList<Integer>();
//		List<Integer> existingSubTaskFieldIdList = new ArrayList<Integer>();
//
//		List<X_pi_report_task> reportTasks = PI_Report.getTasksforReport(reportId, ctx, trxName);
//		reportTasks.forEach(task -> {
//			existingTaskIdList.add(task.get_ID());
//
//			List<X_pi_report_subtask> reportSubTasks = PI_Report.getSubTasksforTask(task.get_ID(), ctx, trxName);
//			reportSubTasks.forEach(subTask -> {
//				existingSubTaskIdList.add(subTask.get_ID());
//
//				List<X_pi_report_subtask_field> fieldList = PI_Report.getFieldsforSubTask(subTask.get_ID(), ctx,
//						trxName);
//				fieldList.forEach(subTaskField -> {
//					existingSubTaskFieldIdList.add(subTaskField.get_ID());
//				});
//
//			});
//
//		});
//
//		for (ReportTask task : request.getTasks()) {
//
//			X_pi_report_task pi_report_task = new X_pi_report_task(ctx, task.getPiReportTaskID(), trxName);
//			int taskId = task.getPiReportTaskID();
//			int indexToRemove = existingTaskIdList.indexOf(taskId);
//
//			if (existingTaskIdList.contains(taskId))
//				existingTaskIdList.remove(indexToRemove);
//			else {
//				pi_report_task.setDescription(task.getDescription());
//				pi_report_task.setName(task.getName());
//				pi_report_task.setStatus(task.getStatus());
//				pi_report_task.setarea(task.getArea());
//				pi_report_task.setPriority(task.getPriority());
//				pi_report_task.settags(task.getTags());
//				pi_report_task.setpi_report_ID(report.get_ID());
//
//				if (!pi_report_task.save(trxName)) {
//					return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity("Failed to create Report")
//							.build();
//				}
//			}
//
//			for (ReportSubTask subtask : task.getSubTasks()) {
//				int subTaskId = subtask.getPiReportSubTaskID();
//				int index = existingSubTaskIdList.indexOf(subTaskId);
//				if (existingSubTaskIdList.contains(subTaskId))
//					existingSubTaskIdList.remove(index);
//				else {
//
//					X_pi_report_subtask pi_report_subtask = new X_pi_report_subtask(ctx, 0, trxName);
//					pi_report_subtask.setDescription(subtask.getDescription());
//					pi_report_subtask.setName(subtask.getName());
//					pi_report_subtask.setStatus(subtask.getStatus());
//					pi_report_subtask.setarea(subtask.getArea());
//					pi_report_subtask.setPriority(subtask.getPriority());
//					pi_report_subtask.settags(subtask.getTags());
//					pi_report_subtask.setpi_report_subtask_ID(pi_report_task.get_ID());
//
//					if (!pi_report_subtask.save(trxName)) {
//						return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity("Failed to create Report")
//								.build();
//					}
//
//					subtask.setPiReportSubTaskID(pi_report_subtask.get_ID());
//				}
//
//				List<ReportSubtaskInspection> inspectionsList = subtask.getInspections();
//				if (inspectionsList != null)
//					for (ReportSubtaskInspection inspection : inspectionsList) {
//
//						List<ReportSubTaskField> fields = inspection.getFields();
//						for (ReportSubTaskField field : fields) {
//							int fieldId = field.getPiReportSubTaskFieldID();
//							int fieldIndex = existingSubTaskFieldIdList.indexOf(fieldId);
//							if (existingSubTaskFieldIdList.contains(fieldId))
//								existingSubTaskFieldIdList.remove(fieldIndex);
//							else {
//
//								X_pi_report_subtask_field pi_report_subtask_field = new X_pi_report_subtask_field(ctx,
//										0, trxName);
//								pi_report_subtask_field.setDescription(field.getDescription());
//								pi_report_subtask_field.setName(field.getName());
//								pi_report_subtask_field.setconfig(field.getConfig());
//								pi_report_subtask_field.sethelptext(field.getHelptext());
//								pi_report_subtask_field.setlabelname(field.getLabelname());
//								pi_report_subtask_field.setpi_report_subtask_ID(subtask.getPiReportSubTaskID());
//								pi_report_subtask_field.setstepname(field.getStepName());
//								pi_report_subtask_field.setstepno(field.getStepNo());
//								pi_report_subtask_field.setisrequired(field.isRequired());
//								pi_report_subtask_field.setInspection(inspection.getInspection());
//								pi_report_subtask_field.saveEx();
//							}
//						}
//					}
//			}
//
//		}
//
//		existingSubTaskFieldIdList.forEach(id -> {
//			try {
//				new X_pi_report_subtask_field(ctx, id, trxName).deleteEx(true);
//			} catch (Exception e) {
//
//			}
//		});
//
//		existingSubTaskIdList.forEach(id -> {
//			try {
//				new X_pi_report_subtask(ctx, id, trxName).deleteEx(true);
//			} catch (Exception e) {
//
//			}
//		});
//
//		existingTaskIdList.forEach(id -> {
//			try {
//				new X_pi_report_task(ctx, id, trxName).deleteEx(true);
//			} catch (Exception e) {
//
//			}
//		});
//
//		return getReportById(report.get_ID());
//	}

	@Override
	public Response updateReport(Report request) {
		Properties ctx = Env.getCtx();
		String trxName = null;

		int roleId = Env.getAD_Role_ID(ctx);
		int clientId = Env.getAD_Client_ID(ctx);
		AdClient_custom adClient = new AdClient_custom(ctx, clientId, trxName);

		AdRole_Custom role = new AdRole_Custom(ctx, roleId, trxName);
		if (!adClient.isSingleuser() && (!role.isAdministrator() && !role.isProjectManager()
				&& !role.isInspectioncontroller() && !role.isDocumentController())) {
			return Response.status(Status.NOT_FOUND).entity(
					new ErrorBuilder().status(Status.NOT_FOUND).title("User Dont have API Acess").build().toString())
					.build();
		}

		PI_Report report = new PI_Report(ctx, request.getPiReportID(), trxName);
		if (report.get_ID() == 0) {
			return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity("Invalid Report").build();
		}

		List<ReportTask> taskList = request.getTasks();
		if (taskList != null && taskList.size() != 0)
			for (ReportTask reqTask : taskList) {
				X_pi_report_task task = new X_pi_report_task(ctx, reqTask.getPiReportTaskID(), trxName);
				task.setChecked(reqTask.isChecked());
				task.save();

				List<ReportSubTask> subTaskList = reqTask.getSubTasks();
				if (subTaskList != null && subTaskList.size() != 0)
					for (ReportSubTask reqSubTask : subTaskList) {
						X_pi_report_subtask subTask = new X_pi_report_subtask(ctx, reqSubTask.getPiReportSubTaskID(),
								trxName);
						subTask.setChecked(reqSubTask.isChecked());
						subTask.save();

						List<ReportSubtaskInspection> inspectionsList = reqSubTask.getInspections();
						if (inspectionsList != null && inspectionsList.size() != 0)
							for (ReportSubtaskInspection inspection : inspectionsList) {

								List<ReportSubTaskField> subTaskfieldList = inspection.getFields();
								if (subTaskfieldList != null && subTaskfieldList.size() != 0)
									for (ReportSubTaskField reqSubTaskField : subTaskfieldList) {
										X_pi_report_subtask_field subTaskField = new X_pi_report_subtask_field(ctx,
												reqSubTaskField.getPiReportSubTaskFieldID(), trxName);
										subTaskField.setChecked(reqSubTaskField.isChecked());
										subTaskField.save();
									}

							}
					}

			}
		return getReportById(report.get_ID());
	}

	@Override
	public Response deleteReport(int id) {
		Properties ctx = Env.getCtx();
		String trxName = null;

		int roleId = Env.getAD_Role_ID(ctx);
		int clientId = Env.getAD_Client_ID(ctx);
		AdClient_custom adClient = new AdClient_custom(ctx, clientId, trxName);

		AdRole_Custom role = new AdRole_Custom(ctx, roleId, trxName);
		if (!adClient.isSingleuser() && (!role.isAdministrator() && !role.isProjectManager()
				&& !role.isInspectioncontroller() && !role.isDocumentController())) {
			return Response.status(Status.NOT_FOUND).entity(
					new ErrorBuilder().status(Status.NOT_FOUND).title("User Dont have API Acess").build().toString())
					.build();
		}

		PI_Report report = new PI_Report(ctx, id, trxName);

		if (report == null || report.get_ID() == 0) {
			return Response.status(Status.NOT_FOUND)
					.entity(new ErrorBuilder().status(Status.NOT_FOUND).title("Report not found").build().toString())
					.build();
		}

		List<X_pi_report_task> reportTasks = PI_Report.getTasksforReport(id, ctx, trxName);
		reportTasks.forEach(task -> {

			List<X_pi_report_subtask> reportSubTasks = PI_Report.getSubTasksforTask(task.get_ID(), ctx, trxName);
			reportSubTasks.forEach(subTask -> {

				List<X_pi_report_subtask_field> fieldList = PI_Report.getFieldsforSubTask(subTask.get_ID(), ctx,
						trxName);
				fieldList.forEach(subTaskField -> {
					subTaskField.delete(true);
				});

				subTask.delete(true);
			});

			task.delete(true);

		});

		if (!report.delete(true)) {
			return Response.status(Status.INTERNAL_SERVER_ERROR).entity(new ErrorBuilder()
					.status(Status.INTERNAL_SERVER_ERROR).title("Failed to delete report").build().toString()).build();
		}

		return Response.status(Status.OK).entity(
				new StandardResponse().status(Status.OK).title("Report deleted successfully").build().toString())
				.build();
	}

	@Override
	public Response createUpdateReportOrgConfig(ReportOrgConfig request) {
		Properties ctx = Env.getCtx();
		String trxName = null;
		ReportOrgConfig res = new ReportOrgConfig();

		int orgId = Env.getAD_Org_ID(ctx);
		int clientId = Env.getAD_Client_ID(ctx);
		PO po = PI_Org_ReportConfig.getReportOrgConfig(ctx, trxName, orgId, clientId);

		int id = 0;
		if (po != null)
			id = po.get_ID();

		PI_Org_ReportConfig config = new PI_Org_ReportConfig(ctx, id, trxName);
		config.setprojecttitle(request.getProjectTitle());
		config.setthemecolour(request.getThemeColour());
		config.setAD_Org_ID(orgId);

		if (!config.save(trxName)) {
			return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
					.entity("Failed to create/ update report org config").build();
		}

		res.setProjectTitle(config.getprojecttitle());
		res.setThemeColour(config.getthemecolour());
		res.setTableID(config.get_ID());
		res.setOrgID(orgId);
		res.setReportOrgConfigID(config.get_ID());

		return Response.ok(res).build();
	}

	@Override
	public Response getReportOrgConfig() {
		Properties ctx = Env.getCtx();
		String trxName = null;
		ReportOrgConfig res = new ReportOrgConfig();

		int orgId = Env.getAD_Org_ID(ctx);
		int clientId = Env.getAD_Client_ID(ctx);
		PO po = PI_Org_ReportConfig.getReportOrgConfig(ctx, trxName, orgId, clientId);

		String projectTitle = null;
		String themeColour = null;
		int id = 0;
		int tableId = 0;
		int lastIndex = 0;
		if (po != null && po.get_ID() != 0) {
			PI_Org_ReportConfig config = new PI_Org_ReportConfig(ctx, po.get_ID(), trxName);
			projectTitle = config.getprojecttitle();
			themeColour = config.getthemecolour();
			tableId = config.get_Table_ID();
			id = po.get_ID();

			MAttachment attachment = po.getAttachment();
			if (attachment != null) {
				lastIndex = attachment.getEntries().length - 1;
			}
		}

		res.setLastIndex(lastIndex);
		res.setProjectTitle(projectTitle);
		res.setThemeColour(themeColour);
		res.setTableID(tableId);
		res.setOrgID(orgId);
		res.setReportOrgConfigID(id);

		return Response.ok(res).build();
	}

//	@Override
//	public Response download(int reportId) {
//		Properties ctx = Env.getCtx();
//		String trxName = null;
//
//		int clientId = Env.getAD_Client_ID(ctx);
////		int orgId = Env.getAD_Org_ID(ctx);
//		int roleId = Env.getAD_Role_ID(ctx);
//		int userId = Env.getAD_User_ID(ctx);
//
//		AdRole_Custom role = new AdRole_Custom(ctx, roleId, trxName);
////		AdOrg_Custom adOrg = new AdOrg_Custom(ctx, orgId, trxName);
//		AdClient_custom adClient = new AdClient_custom(ctx, clientId, trxName);
//		MUser mUser = new MUser(ctx, userId, trxName);
//
//		if (!adClient.isSingleuser() && (!role.isAdministrator() && !role.isProjectManager()
//				&& !role.isInspectioncontroller() && !role.isDocumentController())) {
//			return Response.status(Status.NOT_FOUND).entity(
//					new ErrorBuilder().status(Status.NOT_FOUND).title("User Dont have API Acess").build().toString())
//					.build();
//		}
//
//		PI_Report report = new PI_Report(ctx, reportId, trxName);
//		if (report == null || report.get_ID() == 0)
//			return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity("Invalid Report").build();
//
//		Document document = new Document();
//		ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
//
//		try {
//
//			PdfWriter pdfWriter = PdfWriter.getInstance(document, outputStream);
//			document.open();
//			
//			File file = null;
//			MAttachment attachment = report.getAttachment();
//			if (attachment != null && attachment.get_ID() != 0) {
//				MAttachmentEntry[] entries = attachment.getEntries();
//				if (entries != null && entries.length != 0) {
//					MAttachmentEntry entry = attachment.getEntry(0);
//					file = entry.getFile();
//				}
//			}
//
//			if (file != null && file.exists()) {
//				BufferedImage bufferedImage = ImageIO.read(file);
//				if (bufferedImage != null) {
//					Image pdfImage = Image.getInstance(pdfWriter, bufferedImage, 1);
//					pdfImage.scaleToFit(document.getPageSize().getWidth(), document.getPageSize().getHeight());
//					pdfImage.setAbsolutePosition(0, 0);
//					document.add(pdfImage);
//				}
//			}
//
//			document.add(new Paragraph(report.getprojecttitle()));
//			document.add(new Paragraph("Report Prepared by"));
//			document.add(new Paragraph(mUser.getName()));
//
//		} catch (Exception e) {
//			e.printStackTrace();
//			return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity("Error creating PDF").build();
//		} finally {
//			document.close();
//		}
//
//		ResponseBuilder response = Response.ok(outputStream.toByteArray());
//		response.header("Content-Disposition", "attachment; filename=\"hello_world.pdf\"");
//		response.type("application/pdf");
//
//		return response.build();
//	}

//	@Override
//	public Response download(int reportId) {
//		ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
//		Properties ctx = Env.getCtx();
//		String trxName = null;
//
//		PreparedStatement pstmt = null;
//		ResultSet rs = null;
//		List<Map<String, Object>> parametersList = new ArrayList<>();
//		try {
//
//			PO po = new Query(ctx, MSysConfig.Table_Name, "name ='Stonex_Jasper_Report'", trxName).first();
//			if (po != null && po.get_ID() == 0)
//				return Response
//						.status(Status.INTERNAL_SERVER_ERROR).entity(new ErrorBuilder()
//								.status(Status.INTERNAL_SERVER_ERROR).title("No Config found").build().toString())
//						.build();
//
////			String jasperFilePath = "/home/mahe/Downloads/StonexL.jrxml";
//
////			JasperReport jasperReport = JasperCompileManager.compileReport(jasperFilePath);
//        JasperReport jasperReport = JasperCompileManager.compileReport(po.getAttachment().getEntry(0).getInputStream());
//
//			byte[] stonex_icon = null;
//			po = new Query(ctx, MSysConfig.Table_Name, "name ='ZK_LOGIN_ICON'", trxName).first();
//			if (po != null && po.get_ID() != 0)
//				stonex_icon = po.getAttachment().getEntry(0).getData();
//
//			if (jasperReport == null) {
//				return Response.status(Response.Status.NOT_FOUND).entity("Jasper file not found: " + jasperReport)
//						.build();
//			}
//
//			String sql = "SELECT pr.pi_report_ID AS report_id,pr.projecttitle AS project_title,pr.clientName AS client_name,pr.created as report_date,pr.createdby, pr.reporttitle AS report_title, pr.address AS report_address, pr.status AS report_status,adrep.binarydata AS report_binarydata,\n"
//					+ "prt.pi_report_task_ID AS task_id,prt.name AS task_title,prt.description AS task_description,prt.status AS task_status,adret.binarydata AS task_binarydata,\n"
//					+ "prs.pi_report_subtask_ID AS subtask_id,prs.name AS subtask_title,prs.description AS subtask_description,prs.status AS subtask_status,prs.assignedto AS subtask_assigned_to,\n"
//					+ "adrest.binarydata AS subtask_binarydata,prsf.inspection AS inspection,prsf.comments AS field_comments,prsf.config AS field_config,\n"
//					+ "prsf.pi_report_subtask_field_ID AS field_id,prsf.name AS field_name,prsf.description AS field_description,prsf.labelname AS field_label,\n"
//					+ "prsf.helptext AS field_help,prsf.isrequired AS field_required,prsf.stepno AS step_number,prsf.stepname AS step_name FROM adempiere.pi_report pr\n"
//					+ "JOIN adempiere.pi_report_task prt ON pr.pi_report_ID = prt.pi_report_ID\n"
//					+ "JOIN adempiere.pi_report_subtask prs ON prt.pi_report_task_ID = prs.pi_report_task_ID\n"
//					+ "JOIN adempiere.pi_report_subtask_field prsf ON prs.pi_report_subtask_ID = prsf.pi_report_subtask_ID\n"
//					+ "left JOIN adempiere.ad_attachment adrep on adrep.ad_table_id = 1000016 and adrep.record_id = pr.pi_report_id\n"
//					+ "left JOIN adempiere.ad_attachment adret on adret.ad_table_id = 1000018 and adret.record_id = prt.pi_report_task_id\n"
//					+ "left JOIN adempiere.ad_attachment adrest on adrest.ad_table_id = 1000019 and adrest.record_id = prs.pi_report_subtask_id\n"
//					+ "WHERE  pr.pi_report_id =" + reportId
//					+ " ORDER BY pr.pi_report_ID,prt.pi_report_task_ID,prs.pi_report_subtask_ID,prsf.inspection,prsf.stepno,prsf.pi_report_subtask_field_ID;\n"
//					+ "";
//
//			pstmt = DB.prepareStatement(sql, null);
//			rs = pstmt.executeQuery();
//
//			PI_Report report = new PI_Report(ctx, reportId, trxName);
//			while (rs.next()) {
//				HashMap<String, Object> parameters = new HashMap<>();
//				byte[] report_binarydata = null;
//				byte[] task_binarydata = null;
//				byte[] subtask_binarydata = null;
//
//				int report_id = rs.getInt("report_id");
//				String report_title = rs.getString("report_title");
//				String report_address = rs.getString("report_address");
//				String report_date = rs.getString("report_date");
//				int createdby = rs.getInt("createdby");
//				MUser user = new MUser(ctx, createdby, trxName);
//				String report_createdby = user.getName();
//				String client_name = rs.getString("client_name");
//				String project_title = rs.getString("project_title");
//
//				try {
//					byte[] zipData = rs.getBytes("report_binarydata");
//					if (zipData != null) {
//						report_binarydata = extractImageFromZip(zipData);
//					}
//				} catch (Exception e) {
//					System.err.println("Error extracting report image: " + e.getMessage());
//				}
//
//				try {
//					byte[] zipDataT = rs.getBytes("task_binarydata");
//					if (zipDataT != null) {
//						task_binarydata = extractImageFromZip(zipDataT);
//					}
//				} catch (Exception e) {
//					System.err.println("Error extracting Task image: " + e.getMessage());
//				}
//
//				try {
//					byte[] zipDataS = rs.getBytes("subtask_binarydata");
//					if (zipDataS != null) {
//						subtask_binarydata = extractImageFromZip(zipDataS);
//					}
//				} catch (Exception e) {
//					System.err.println("Error extracting Sub Task image: " + e.getMessage());
//				}
//
//				int task_id = rs.getInt("task_id");
//				String task_title = rs.getString("task_title");
//
//				int subtask_id = rs.getInt("subtask_id");
//				String subtask_title = rs.getString("subtask_title");
//
//				int inspection = rs.getInt("inspection");
//
//				int field_id = rs.getInt("field_id");
//				String field_name = rs.getString("field_name");
//
//				String field_comments = rs.getString("field_comments");
//				// Handle NULL and empty strings properly
//				if (field_comments == null) {
//					field_comments = ""; // Or "No comments" if you prefer
//				} else {
//					field_comments = field_comments.trim();
//				}
//
//				String field_config = rs.getString("field_config");
//				if (field_config == null) {
//					field_config = "";
//				} else {
//					field_config = field_config.trim();
//				}
//				
//				parameters.put("report_id", report_id);
//				parameters.put("report_title", report_title + " - " + report_id);
//				parameters.put("report_binarydata", report_binarydata);
//				parameters.put("task_id", task_id);
//				parameters.put("task_title", task_title + " - " + task_id);
//				parameters.put("task_binarydata", task_binarydata);
//				parameters.put("subtask_id", subtask_id);
//				parameters.put("subtask_title", subtask_title + " - " + subtask_id);
//				parameters.put("subtask_binarydata", subtask_binarydata);
//				parameters.put("inspection", inspection);
//				parameters.put("field_id", field_id);
//				parameters.put("field_name", field_name + " - " + field_id);
//				parameters.put("field_comments", field_comments);
//				parameters.put("stonex_icon", stonex_icon);
//				parameters.put("report_address", report_address);
//				parameters.put("report_date", report_date);
//				parameters.put("report_createdby", report_createdby);
//				parameters.put("client_name", client_name);
//				parameters.put("project_title", project_title);
//
//				if (field_config != null)
////           Map<String, Object> processed = processField("Dropdown", field_config, true);
//					field_config = processField(field_name, field_config, true).toString();
//
//				parameters.put("field_config", field_config);
//				parametersList.add(parameters);
//			}
//
//			if (parametersList.isEmpty()) {
//				System.out.println("No data found!");
//				return Response.status(Response.Status.NO_CONTENT).entity("No data available for the report").build();
//			}
//			JRDataSource dataSource = new JRBeanCollectionDataSource(parametersList);
//			HashMap<String, Object> reportParams = new HashMap<>();
//			reportParams.put("Title", "Stonex Report");
//
//			String themeColor = report.getthemecolour();
//			if (themeColor == null)
//				themeColor = "#0bf78f";
//
//			reportParams.put("Background_color", themeColor);
//
//			JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, reportParams, dataSource);
//
//			JasperExportManager.exportReportToPdfStream(jasperPrint, outputStream);
//
//			return Response.ok(outputStream.toByteArray()).header("Content-Type", "application/pdf")
//					.header("Content-Disposition", "attachment; filename=\"stonex_report.pdf\"")
//					.header("Content-Length", outputStream.size()).build();
//		} catch (Exception e) {
//			return Response.serverError().entity("Error generating report: " + e.getMessage()).build();
//		} finally {
//			DB.close(rs, pstmt);
//		}
//	}

//	@Override
//	public Response download(int reportId) {
//		ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
//		PreparedStatement pstmt = null;
//		ResultSet rs = null;
//		List<Map<String, Object>> parametersList = new ArrayList<>();
//		try {
//			Properties ctx = Env.getCtx();
//			String trxName = null;
//
//			PI_Report report = new PI_Report(ctx, reportId, trxName);
//
//			if (report == null || report.get_ID() == 0) {
//				return Response.status(Status.NOT_FOUND).entity(
//						new ErrorBuilder().status(Status.NOT_FOUND).title("Report not found").build().toString())
//						.build();
//			}
//
//			PO po = new Query(ctx, MSysConfig.Table_Name, "name ='Stonex_Jasper_Report'", trxName).first();
//
//			if (po != null && po.get_ID() == 0)
//				return Response
//						.status(Status.INTERNAL_SERVER_ERROR).entity(new ErrorBuilder()
//								.status(Status.INTERNAL_SERVER_ERROR).title("No Config found").build().toString())
//						.build();
//
////	        PI_Report report = new PI_Report(ctx, reportId, trxName);
//
////			String jasperFilePath = "/home/mahe/Downloads/StonexP.jrxml";
////			JasperCompileManager.compileReportToFile(jasperFilePath);
////			JasperReport jasperReport = JasperCompileManager.compileReport(jasperFilePath);
//
//			JasperReport jasperReport = JasperCompileManager
//					.compileReport(po.getAttachment().getEntry(0).getInputStream());
//			if (jasperReport == null) {
//				return Response.status(Response.Status.NOT_FOUND).entity("Jasper file not found: " + jasperReport)
//						.build();
//			}
//
////			byte[] stonex_icon = null;
////			po = new Query(ctx, MSysConfig.Table_Name, "name ='ZK_LOGIN_ICON'", trxName).first();
////			if (po != null && po.get_ID() != 0)
////				stonex_icon = po.getAttachment().getEntry(0).getData();
//
//			String sql = "SELECT pr.pi_report_ID AS report_id,pr.projecttitle AS project_title,pr.reporttitle AS report_title,pr.status AS report_status,adrep.binarydata AS report_binarydata,\n"
//					+ "prt.pi_report_task_ID AS task_id, pr.createdby, prt.name AS task_title,prt.description AS task_description,prt.status AS task_status,adret.binarydata AS task_binarydata,\n"
//					+ "prs.pi_report_subtask_ID AS subtask_id,prs.name AS subtask_title,prs.description AS subtask_description,prs.status AS subtask_status,prs.assignedto AS subtask_assigned_to,\n"
//					+ "adrest.binarydata AS subtask_binarydata,prsf.inspection AS inspection,prsf.comments AS field_comments,prsf.config AS field_config,\n"
//					+ "prsf.pi_report_subtask_field_ID AS field_id,prsf.name AS field_name,prsf.description AS field_description,prsf.labelname AS field_label,\n"
//					+ "prsf.helptext AS field_help,prsf.isrequired AS field_required,prsf.stepno AS step_number,prsf.stepname AS step_name FROM adempiere.pi_report pr\n"
//					+ "JOIN adempiere.pi_report_task prt ON pr.pi_report_ID = prt.pi_report_ID\n"
//					+ "JOIN adempiere.pi_report_subtask prs ON prt.pi_report_task_ID = prs.pi_report_task_ID\n"
//					+ "JOIN adempiere.pi_report_subtask_field prsf ON prs.pi_report_subtask_ID = prsf.pi_report_subtask_ID\n"
//					+ "left JOIN adempiere.ad_attachment adrep on adrep.ad_table_id = 1000016 and adrep.record_id = pr.pi_report_id\n"
//					+ "left JOIN adempiere.ad_attachment adret on adret.ad_table_id = 1000018 and adret.record_id = prt.pi_report_task_id\n"
//					+ "left JOIN adempiere.ad_attachment adrest on adrest.ad_table_id = 1000019 and adrest.record_id = prs.pi_report_subtask_id\n"
//					+ "WHERE  pr.pi_report_id =" + reportId
//					+ " ORDER BY pr.pi_report_ID,prt.pi_report_task_ID,prs.pi_report_subtask_ID,prsf.inspection,prsf.stepno,prsf.pi_report_subtask_field_ID;\n"
//					+ "";
//			pstmt = DB.prepareStatement(sql, null);
//			rs = pstmt.executeQuery();
//			while (rs.next()) {
//				HashMap<String, Object> parameters = new HashMap<>();
//				byte[] field_binarydata = null;
//				try {
//					byte[] zipData = rs.getBytes("subtask_binarydata");
//					if (zipData != null) {
//						field_binarydata = extractImageFromZip(zipData);
//					}
//				} catch (Exception e) {
//					System.err.println("Error extracting field image: " + e.getMessage());
//				}
//
////				byte[] binarydata = null;
////
////				try {
////					byte[] zipData = rs.getBytes("report_binarydata");
////					if (zipData != null) {
////						binarydata = extractImageFromZip(zipData);
////					}
////				} catch (Exception e) {
////					System.err.println("Error extracting field image: " + e.getMessage());
////				}
////				parameters.put("stonex_icon", binarydata);
//				
//				MAttachment attachment = report.getAttachment();
//				if (attachment != null) {
//					MAttachmentEntry[] entries = attachment.getEntries();
//					for(MAttachmentEntry entry : entries) {
//						if(entry.getFile().getName().equalsIgnoreCase("logo.png")) {
//							parameters.put("stonex_icon", entry.getData());
//							break;
//						}
//					}
//				}
//				
//
//				int task_id = rs.getInt("task_id");
//				String task_title = rs.getString("task_title");
//				int subtask_id = rs.getInt("subtask_id");
//				String subtask_title = rs.getString("subtask_title");
//				int inspection = rs.getInt("inspection");
//				int step_number = rs.getInt("step_number");
//				String field_name = rs.getString("field_name");
//				String field_comments = rs.getString("field_comments");
//				String field_comments_name = "Comments : ";
//				String field_config = rs.getString("field_config");
//				String report_title = rs.getString("report_title");
//
//				int field_id = rs.getInt("field_id");
//				X_pi_report_subtask_field field = new X_pi_report_subtask_field(ctx, field_id, trxName);
//
//				if (field.getAttachment() != null && field.getAttachment().getEntryCount() > 0) {
//					try {
//						field_binarydata = field.getAttachment().getEntry(0).getData();
//					} catch (Exception e) {
//						System.out.println("Error getting attachment data: " + e.getMessage());
//					}
//				}
//
//				int createdby = rs.getInt("createdby");
//				MUser user = new MUser(ctx, createdby, trxName);
//				String report_createdby = user.getName();
//
//				parameters.put("report_title", report_title);
//
//				parameters.put("report_createdby", report_createdby);
//				parameters.put("createdfor", "Inspection");
//
//				parameters.put("task_id", task_id);
//				parameters.put("subtask_id", subtask_id);
//				parameters.put("subtask_title", subtask_title);
//				parameters.put("inspection", inspection);
//				parameters.put("step_number", step_number);
//				parameters.put("field_name", field_name);
//				parameters.put("field_binarydata", field_binarydata);
//								
//				X_pi_project pi_project = report.getpi_project();
//				attachment = pi_project.getAttachment();
//				if (attachment != null) {
//					MAttachmentEntry[] entries = attachment.getEntries();
//					for(MAttachmentEntry entry : entries) {
//						if(entry.getFile().getName().equalsIgnoreCase("profile.png")) {
//							parameters.put("binarydata", entry.getData());
//							break;
//						}
//					}
//				}
//				
//
//				parameters.put("task_title", (task_title != null) ? task_title : "");
//				parameters.put("subtask_title", (subtask_title != null) ? subtask_title : "");
//
//				if (field_binarydata != null) {
//					parameters.put("field_binarydata", field_binarydata);
//
//					if (field_comments != null) {
//						parameters.put("field_comments", field_comments);
//						parameters.put("field_comments_name", field_comments_name);
//					} else {
//						parameters.put("field_comments", "");
//						parameters.put("field_comments_name", "");
//					}
//
//				} else {
//					if (field_config != null) {
//						field_config = processField(field_name, field_config, true).toString();
//						parameters.put("field_config", (field_config != null) ? field_config : "");
//					}
//
//					if (field_comments != null) {
//						parameters.put("field_comments", field_comments);
//						parameters.put("field_comments_name", field_comments_name);
//					} else {
//						parameters.put("field_comments", "");
//						parameters.put("field_comments_name", "");
//					}
//				}
//				parametersList.add(parameters);
//			}
//			if (parametersList.isEmpty()) {
//				System.out.println("No data found!");
//				return Response.status(Response.Status.NO_CONTENT).entity("No data available for the report").build();
//			}
//			JRDataSource dataSource = new JRBeanCollectionDataSource(parametersList);
//			HashMap<String, Object> reportParams = new HashMap<>();
//
//			reportParams.put("Background_color", "#F8B200");
//			String themeColor = report.getthemecolour();
//			if (themeColor == null)
//				themeColor = "#F8B200";
//			reportParams.put("Background_color", themeColor);
//			JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, reportParams, dataSource);
//			JasperExportManager.exportReportToPdfStream(jasperPrint, outputStream);
//			return Response.ok(outputStream.toByteArray()).header("Content-Type", "application/pdf")
//					.header("Content-Disposition", "attachment; filename=\"stonex_report.pdf\"")
//					.header("Content-Length", outputStream.size()).build();
//		} catch (Exception e) {
//			return Response.serverError().entity("Error generating report: " + e.getMessage()).build();
//		} finally {
//			DB.close(rs, pstmt);
//		}
//
//	}

//	@Override
//	public Response download(int reportId) {
//		ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
//		List<Map<String, Object>> parametersList = new ArrayList<>();
//		try {
//			Properties ctx = Env.getCtx();
//			String trxName = null;
//
//			PI_Report report = new PI_Report(ctx, reportId, trxName);
//
//			if (report == null || report.get_ID() == 0) {
//				return Response.status(Status.NOT_FOUND).entity(
//						new ErrorBuilder().status(Status.NOT_FOUND).title("Report not found").build().toString())
//						.build();
//			}
//
//			PO po = new Query(ctx, MSysConfig.Table_Name, "name ='Stonex_Jasper_Report'", trxName).first();
//
//			if (po != null && po.get_ID() == 0)
//				return Response
//						.status(Status.INTERNAL_SERVER_ERROR).entity(new ErrorBuilder()
//								.status(Status.INTERNAL_SERVER_ERROR).title("No Config found").build().toString())
//						.build();
//
////			String jasperFilePath = "/home/mahe/Downloads/StonexP.jrxml";
////			JasperCompileManager.compileReportToFile(jasperFilePath);
////			JasperReport jasperReport = JasperCompileManager.compileReport(jasperFilePath);
//
//			JasperReport jasperReport = JasperCompileManager
//					.compileReport(po.getAttachment().getEntry(0).getInputStream());
//			if (jasperReport == null) {
//				return Response.status(Response.Status.NOT_FOUND).entity("Jasper file not found: " + jasperReport)
//						.build();
//			}
//
////			Report res = getReportDetail(reportId, ctx, trxName, orgId, clientId);
//			List<X_pi_report_subtask_field> fieldList = PI_Report.getFieldsforReport(reportId, ctx, trxName, true);
//
//			for (X_pi_report_subtask_field field : fieldList) {
//
//				if (!validateField(field.getName(), field.getconfig(), field.get_ID(), ctx))
//					continue;
//
//				X_pi_report_subtask subTask = new X_pi_report_subtask(ctx, field.getpi_report_subtask_ID(), trxName);
//				X_pi_report_task task = new X_pi_report_task(ctx, subTask.getpi_report_task_ID(), trxName);
//
//				HashMap<String, Object> parameters = new HashMap<>();
//
//				byte[] field_binarydata = null;
//				if (subTask.getAttachment() != null && subTask.getAttachment().getEntryCount() > 0)
//					try {
//						field_binarydata = subTask.getAttachment().getEntry(0).getData();
//
//					} catch (Exception e) {
//						System.err.println("Error extracting field image: " + e.getMessage());
//					}
//
//				MAttachment attachment = report.getAttachment();
//				if (attachment != null) {
//					MAttachmentEntry[] entries = attachment.getEntries();
//					for (MAttachmentEntry entry : entries) {
//						if (entry.getFile().getName().equalsIgnoreCase("logo.png")) {
//							parameters.put("stonex_icon", entry.getData());
//							break;
//						}
//					}
//				}
//
//				int task_id = task.get_ID();
//				String task_title = task.getName();
//				int subtask_id = subTask.get_ID();
//				String subtask_title = subTask.getName();
//				int inspection = field.getInspection();
//				int step_number = field.getstepno();
//				String field_name = field.getName();
//				String field_comments = field.getComments();
//				String field_comments_name = "Comments : ";
//				String field_config = field.getconfig();
//				String report_title = report.getreporttitle();
//
//				if (field.getAttachment() != null && field.getAttachment().getEntryCount() > 0)
//					try {
//						field_binarydata = field.getAttachment().getEntry(0).getData();
//					} catch (Exception e) {
//						System.out.println("Error getting attachment data: " + e.getMessage());
//					}
//
//				int createdby = report.getCreatedBy();
//				MUser user = new MUser(ctx, createdby, trxName);
//				String report_createdby = user.getName();
//
//				parameters.put("report_title", report_title);
//
//				parameters.put("report_createdby", report_createdby);
//				parameters.put("createdfor", "Inspection");
//
//				parameters.put("task_id", task_id);
//				parameters.put("subtask_id", subtask_id);
//				parameters.put("subtask_title", subtask_title);
//				parameters.put("inspection", inspection);
//				parameters.put("step_number", step_number);
//				parameters.put("field_name", field_name);
//				parameters.put("field_binarydata", field_binarydata);
//
//				X_pi_project pi_project = report.getpi_project();
//				attachment = pi_project.getAttachment();
//				if (attachment != null) {
//					MAttachmentEntry[] entries = attachment.getEntries();
//					for (MAttachmentEntry entry : entries) {
//						if (entry.getFile().getName().equalsIgnoreCase("profile.png")) {
//							parameters.put("binarydata", entry.getData());
//							break;
//						}
//					}
//				}
//
//				parameters.put("task_title", (task_title != null) ? task_title : "");
//				parameters.put("subtask_title", (subtask_title != null) ? subtask_title : "");
//
//				if (field_binarydata != null) {
//					parameters.put("field_binarydata", field_binarydata);
//
//					if (field_comments != null) {
//						parameters.put("field_comments", field_comments);
//						parameters.put("field_comments_name", field_comments_name);
//					} else {
//						parameters.put("field_comments", "");
//						parameters.put("field_comments_name", "");
//					}
//
//				} else {
//					if (field_config != null) {
//						field_config = processField(field_name, field_config, true).toString();
//						parameters.put("field_config", (field_config != null) ? field_config : "");
//					}
//
//					if (field_comments != null) {
//						parameters.put("field_comments", field_comments);
//						parameters.put("field_comments_name", field_comments_name);
//					} else {
//						parameters.put("field_comments", "");
//						parameters.put("field_comments_name", "");
//					}
//				}
//				parametersList.add(parameters);
//			}
//			if (parametersList.isEmpty()) {
//				System.out.println("No data found!");
//				return Response.status(Response.Status.NO_CONTENT).entity("No data available for the report").build();
//			}
//			JRDataSource dataSource = new JRBeanCollectionDataSource(parametersList);
//			HashMap<String, Object> reportParams = new HashMap<>();
//
//			reportParams.put("Background_color", "#F8B200");
//			String themeColor = report.getthemecolour();
//			if (themeColor == null)
//				themeColor = "#F8B200";
//			reportParams.put("Background_color", themeColor);
//			JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, reportParams, dataSource);
//			JasperExportManager.exportReportToPdfStream(jasperPrint, outputStream);
//			return Response.ok(outputStream.toByteArray()).header("Content-Type", "application/pdf")
//					.header("Content-Disposition", "attachment; filename=\"stonex_report.pdf\"")
//					.header("Content-Length", outputStream.size()).build();
//		} catch (
//
//		Exception e) {
//			return Response.serverError().entity("Error generating report: " + e.getMessage()).build();
//		}
//
//	}

	@Override
	public Response download(int reportId) {
		ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
		List<Map<String, Object>> parametersList = new ArrayList<>();
		try {
			Properties ctx = Env.getCtx();
			String trxName = null;
			int orgId = Env.getAD_Org_ID(ctx);
			int clientId = Env.getAD_Client_ID(ctx);

			PI_Report report = new PI_Report(ctx, reportId, trxName);

			if (report == null || report.get_ID() == 0) {
				return Response.status(Status.NOT_FOUND).entity(
						new ErrorBuilder().status(Status.NOT_FOUND).title("Report not found").build().toString())
						.build();
			}

			PO po = new Query(ctx, MSysConfig.Table_Name, "name ='Stonex_Jasper_Report'", trxName).first();

			if (po != null && po.get_ID() == 0)
				return Response
						.status(Status.INTERNAL_SERVER_ERROR).entity(new ErrorBuilder()
								.status(Status.INTERNAL_SERVER_ERROR).title("No Config found").build().toString())
						.build();

//			String jasperFilePath = "/home/mahe/Downloads/StonexP.jrxml";
//			JasperCompileManager.compileReportToFile(jasperFilePath);
//			JasperReport jasperReport = JasperCompileManager.compileReport(jasperFilePath);

			JasperReport jasperReport = JasperCompileManager
					.compileReport(po.getAttachment().getEntry(0).getInputStream());
			if (jasperReport == null) {
				return Response.status(Response.Status.NOT_FOUND).entity("Jasper file not found: " + jasperReport)
						.build();
			}

//			List<X_pi_report_subtask_field> fieldList = PI_Report.getFieldsforReport(reportId, ctx, trxName, true);

			Report res = getReportDetail(reportId, ctx, trxName, orgId, clientId);
			if (res != null) {
				List<ReportTask> reportTasks = res.getTasks();
				if (reportTasks != null && reportTasks.size() != 0) {

					for (ReportTask rTask : reportTasks) {
						
						if(!rTask.isChecked())
							continue;

						List<ReportSubTask> subTasks = rTask.getSubTasks();
						if (subTasks != null && subTasks.size() != 0) {

							for (ReportSubTask rSubTask : subTasks) {

								if(!rSubTask.isChecked())
									continue;
								
								List<ReportSubtaskInspection> inspections = rSubTask.getInspections();
								if (inspections != null && inspections.size() != 0) {

									for (ReportSubtaskInspection rInspection : inspections) {

										
										List<ReportSubTaskField> fields = rInspection.getFields();
										if (fields != null && fields.size() != 0) {

											for (ReportSubTaskField rField : fields) {
												
												if(!rField.isChecked())
													continue;

												X_pi_report_subtask_field field = new X_pi_report_subtask_field(ctx,
														rField.getPiReportSubTaskFieldID(), trxName);
												X_pi_report_subtask subTask = new X_pi_report_subtask(ctx,
														field.getpi_report_subtask_ID(), trxName);
												X_pi_report_task task = new X_pi_report_task(ctx,
														subTask.getpi_report_task_ID(), trxName);

												HashMap<String, Object> parameters = new HashMap<>();

												byte[] field_binarydata = null;
												if (subTask.getAttachment() != null
														&& subTask.getAttachment().getEntryCount() > 0)
													try {
														field_binarydata = subTask.getAttachment().getEntry(0)
																.getData();

													} catch (Exception e) {
														System.err.println(
																"Error extracting field image: " + e.getMessage());
													}

												MAttachment attachment = report.getAttachment();
												if (attachment != null) {
													MAttachmentEntry[] entries = attachment.getEntries();
													for (MAttachmentEntry entry : entries) {
														if (entry.getFile().getName().equalsIgnoreCase("logo.png")) {
															parameters.put("stonex_icon", entry.getData());
															break;
														}
													}
												}

												int task_id = task.get_ID();
												String task_title = task.getName();
												int subtask_id = subTask.get_ID();
												String subtask_title = subTask.getName();
												int inspection = field.getInspection();
												int step_number = field.getstepno();
												String field_name = field.getName();
												String field_comments = field.getComments();
												String field_comments_name = "Comments : ";
												String field_config = field.getconfig();
												String report_title = report.getreporttitle();

												if (field.getAttachment() != null
														&& field.getAttachment().getEntryCount() > 0)
													try {
														field_binarydata = field.getAttachment().getEntry(0).getData();
													} catch (Exception e) {
														System.out.println(
																"Error getting attachment data: " + e.getMessage());
													}

												int createdby = report.getCreatedBy();
												MUser user = new MUser(ctx, createdby, trxName);
												String report_createdby = user.getName();

												parameters.put("report_title", report_title);

												parameters.put("report_createdby", report_createdby);
												parameters.put("createdfor", "Inspection");

												parameters.put("task_id", task_id);
												parameters.put("subtask_id", subtask_id);
												parameters.put("subtask_title", subtask_title);
												parameters.put("inspection", inspection);
												parameters.put("step_number", step_number);
												parameters.put("field_name", field_name);
												parameters.put("field_binarydata", field_binarydata);

												X_pi_project pi_project = report.getpi_project();
												attachment = pi_project.getAttachment();
												if (attachment != null) {
													MAttachmentEntry[] entries = attachment.getEntries();
													for (MAttachmentEntry entry : entries) {
														if (entry.getFile().getName().equalsIgnoreCase("profile.png")) {
															parameters.put("binarydata", entry.getData());
															break;
														}
													}
												}

												parameters.put("task_title", (task_title != null) ? task_title : "");
												parameters.put("subtask_title",
														(subtask_title != null) ? subtask_title : "");

												if (field_binarydata != null) {
													parameters.put("field_binarydata", field_binarydata);

													if (field_comments != null) {
														parameters.put("field_comments", field_comments);
														parameters.put("field_comments_name", field_comments_name);
													} else {
														parameters.put("field_comments", "");
														parameters.put("field_comments_name", "");
													}

												} else {
													if (field_config != null) {
														field_config = processField(field_name, field_config, true)
																.toString();
														parameters.put("field_config",
																(field_config != null) ? field_config : "");
													}

													if (field_comments != null) {
														parameters.put("field_comments", field_comments);
														parameters.put("field_comments_name", field_comments_name);
													} else {
														parameters.put("field_comments", "");
														parameters.put("field_comments_name", "");
													}
												}
												parametersList.add(parameters);
											}
										}
									}
								}
							}
						}
					}
				}
			}

			if (parametersList.isEmpty()) {
				return Response.status(Response.Status.NO_CONTENT).entity("No data available for the report").build();
			}
			JRDataSource dataSource = new JRBeanCollectionDataSource(parametersList);
			HashMap<String, Object> reportParams = new HashMap<>();

			reportParams.put("Background_color", "#F8B200");
			String themeColor = report.getthemecolour();
			if (themeColor == null)
				themeColor = "#F8B200";
			reportParams.put("Background_color", themeColor);
			JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, reportParams, dataSource);
			JasperExportManager.exportReportToPdfStream(jasperPrint, outputStream);
			return Response.ok(outputStream.toByteArray()).header("Content-Type", "application/pdf")
					.header("Content-Disposition", "attachment; filename=\"stonex_report.pdf\"")
					.header("Content-Length", outputStream.size()).build();
		} catch (

		Exception e) {
			return Response.serverError().entity("Error generating report: " + e.getMessage()).build();
		}

	}

	public static byte[] extractImageFromZip(byte[] zipData) throws IOException {
		ByteArrayInputStream bis = new ByteArrayInputStream(zipData);
		ZipInputStream zis = new ZipInputStream(bis);
		ZipEntry entry;
		while ((entry = zis.getNextEntry()) != null) {
			if (entry.getName().matches(".*\\.(png|jpg|jpeg|gif)$")) {
				ByteArrayOutputStream bos = new ByteArrayOutputStream();
				byte[] buffer = new byte[1024];
				int len;
				while ((len = zis.read(buffer)) > 0) {
					bos.write(buffer, 0, len);
				}
				zis.closeEntry();
				zis.close();
				return bos.toByteArray();
			}
		}
		zis.close();
		return null;
	}

	public StringBuilder processField(String fieldType, String config, boolean isRequired) {
		StringBuilder builder = new StringBuilder();

		try {
			JSONObject configObj = config.isEmpty() ? new JSONObject() : new JSONObject(config);

			String questionText = (configObj.optString("questionText", ""));
			if (!questionText.equalsIgnoreCase("null")) {
				builder.append(questionText);
			}

			builder.append("\n");
			builder.append("\n");

			// Type-specific processing
			switch (fieldType) {
			case "Short Answer":
				builder.append(configObj.optString("answerText", ""));
				break;

			case "Dropdown":
			case "Checkboxes":
			case "Multiple Choice":
//                builder.append(processOptions(configObj.optJSONArray("options")));
//                builder.append("\n");
				builder.append(getSelectedOptions(configObj.optJSONArray("options")));
				break;

			case "File Upload":
			case "Image Upload":
			case "Video field":
				builder.append("\n");
				break;

			default:
				builder.append(configObj.optString("answerText", ""));
			}

		} catch (Exception e) {
		}

		return builder;
	}

	public boolean validateField(String fieldType, String config, int fieldId, Properties ctx) {

		try {
			JSONObject configObj = config.isEmpty() ? new JSONObject() : new JSONObject(config);

			String ans = null;
			switch (fieldType) {
			case "Short Answer":
				ans = configObj.optString("answerText", null);
				if (ans == null)
					return false;
				break;

			case "Dropdown":
			case "Checkboxes":
			case "Multiple Choice":
				ans = getSelectedOptions(configObj.optJSONArray("options"));

				if (ans == "" || ans.length() < 0)
					return false;
				break;

			case "File Upload":
			case "Image Upload":
			case "Video field":
				X_pi_report_subtask_field field = new X_pi_report_subtask_field(ctx, fieldId, null);
				MAttachment attachment = field.getAttachment();
				if (attachment == null)
					return false;

				if (attachment != null) {
					MAttachmentEntry[] entries = attachment.getEntries();
					if (entries == null || entries.length == 0)
						return false;
				}
				break;

			default:
				return false;
			}

		} catch (Exception e) {
		}

		return true;
	}

	private String getSelectedOptions(JSONArray optionsArray) {
		StringBuilder builder = new StringBuilder();

		List<String> selected = new ArrayList<>();
		if (optionsArray == null)
			return builder.toString();

		for (int i = 0; i < optionsArray.length(); i++) {
			JSONObject option = optionsArray.optJSONObject(i);
			if (option != null && option.optBoolean("selected", false)) {
				selected.add(option.optString("label", ""));
			}
		}

		for (String val : selected) {
			builder.append("   " + val);
			builder.append("\n");
		}
		return builder.toString();
	}

	public static void addFooter(String client, String project, Document document) {
		try {
			PdfPTable footerTable = new PdfPTable(2);
			footerTable.setWidthPercentage(100);

			String footerText = "Client: " + client + " | Project: " + project;
			footerTable.addCell(new Paragraph(footerText));

			File logoFile = new File("/images/stonex_login_logo.svg");
			if (logoFile.exists()) {
				Image logo = Image.getInstance(logoFile.getAbsolutePath());
				logo.scaleToFit(50, 50);
				logo.setAlignment(Image.ALIGN_RIGHT);
				footerTable.addCell(logo);
			} else {
				footerTable.addCell("");
			}

			document.add(footerTable);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public static BufferedImage convertFileToBufferedImage(File file) {
		BufferedImage originalImage = null;
		try {
			originalImage = ImageIO.read(file);

			BufferedImage resizedImage = new BufferedImage(200, 200, BufferedImage.TYPE_INT_ARGB);
			resizedImage.getGraphics().drawImage(originalImage, 0, 0, 200, 200, null);

			return resizedImage;
		} catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}

}
