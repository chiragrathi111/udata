//package org.adempiere.webui.dashboard;
//
//import java.util.Arrays;
//import java.util.concurrent.ThreadLocalRandom;
//import java.util.stream.IntStream;
//
//import org.zkoss.bind.annotation.Command;
//import org.zkoss.bind.annotation.NotifyChange;
//import org.zkoss.zk.ui.event.Event;
//import org.zkoss.zk.ui.event.EventListener;
//
//import tools.dynamia.zk.addons.chartjs.Axe;
//import tools.dynamia.zk.addons.chartjs.CategoryChartjsData;
//import tools.dynamia.zk.addons.chartjs.Chartjs;
//import tools.dynamia.zk.addons.chartjs.ChartjsData;
//import tools.dynamia.zk.addons.chartjs.ChartjsOptions;
//import tools.dynamia.zk.addons.chartjs.Dataset;
//import tools.dynamia.zk.addons.chartjs.GridLine;
//import tools.dynamia.zk.addons.chartjs.Scales;
//import tools.dynamia.zk.addons.chartjs.Tooltips;
//import tools.dynamia.zk.addons.chartjs.XYDataset;
//
//public class DPWidgetTest extends DashboardPanel implements EventListener<Event> {
//
//	private CategoryChartjsData categoryModel;
//	private ChartjsData xyModel;
//	private ChartjsData lineModel;
//	private ChartjsData xyzModel;
//	private ChartjsData radarModel;
//	private ChartjsOptions xyOptions;
//
//	private ChartjsData mixedModel;
//
//	public DPWidgetTest() {
//		load();
//		initXYOptions();
//	}
//
//	private void initXYOptions() {
//
//		xyOptions = new ChartjsOptions();
//		xyOptions.setScales(new Scales()
//				.addY(Axe.Builder.init().type("linear").display(true).position("left").id("y-axis-1").build())
//
//				.addY(Axe.Builder.init().type("linear").display(true).position("right").id("y-axis-2").build()
//						.addGridLine(GridLine.Builder.init().drawOnChartArea(false).build())
//
//				));
//
//		xyOptions.setTooltips(Tooltips.Builder.init().position("nearest").mode("index").intersect(false).build());
//
//	}
//
//	@Command
//	@NotifyChange("*")
//	public void load() {
//		initCategoryModel();
//		initXYModel();
//		initRadarModel();
//		initMixedModel();
//	}
//
//	private void initCategoryModel() {
//		int max = 2000;
//		int min = 500;
//		categoryModel = new CategoryChartjsData();
//
//		categoryModel.setDatasetLabel("Sales by Year").add("2011", ThreadLocalRandom.current().nextInt(min, max))
//				.add("2012", ThreadLocalRandom.current().nextInt(min, max))
//				.add("2013", ThreadLocalRandom.current().nextInt(min, max))
//				.add("2014", ThreadLocalRandom.current().nextInt(min, max))
//				.add("2015", ThreadLocalRandom.current().nextInt(min, max))
//				.add("2016", ThreadLocalRandom.current().nextInt(min, max))
//				.add("2017", ThreadLocalRandom.current().nextInt(min, max))
//				.add("2018", ThreadLocalRandom.current().nextInt(min, max));
//	}
//
//	private void initXYModel() {
//		xyModel = new ChartjsData();
//		xyModel.setLabels("January", "February", "March", "April", "June", "July", "August", "September", "October",
//				"November", "December");
//
//		xyzModel = new ChartjsData();
//		xyzModel.setLabels(xyModel.getLabels());
//		lineModel = new ChartjsData();
//
//		XYDataset dataset1 = new XYDataset("First Dataset");
//		dataset1.setFill(false);
//		dataset1.setBorderColor("#93271d");
//		dataset1.setBackgroundColor("#93271d");
//		dataset1.setLineTension(0);
//
//		xyModel.addDataset(dataset1);
//		lineModel.addDataset(dataset1);
//
//		XYDataset dataset2 = new XYDataset("Second Dataset");
//		dataset2.setFill(false);
//		dataset2.setBorderColor("#2a5eb2");
//		dataset2.setBackgroundColor("#2a5eb2");
//		dataset2.setLineTension(0);
//		xyModel.addDataset(dataset2);
//
//		XYDataset dataset3 = new XYDataset("XYZ Dataset");
//		dataset3.setBorderColor("#2faf3a");
//		dataset3.setBackgroundColor("#2faf3a");
//		xyzModel.addDataset(dataset3);
//
//		int max = 100;
//		int min = 10;
//		int months = 12;
//		for (int i = 0; i < months; i++) {
//			int x = ThreadLocalRandom.current().nextInt(min, max);
//			int y = ThreadLocalRandom.current().nextInt(min, max);
//			dataset1.addData(x, y);
//
//			x = ThreadLocalRandom.current().nextInt(min, max);
//			y = ThreadLocalRandom.current().nextInt(min, max);
//			dataset2.addData(x, y);
//
//			x = ThreadLocalRandom.current().nextInt(min, max);
//			y = ThreadLocalRandom.current().nextInt(min, max);
//			int r = ThreadLocalRandom.current().nextInt(10, 20);
//			dataset3.addData(x, y, r);
//		}
//	}
//
//	private void initRadarModel() {
//		radarModel = new ChartjsData();
//		radarModel.setLabels("Strength", "Speed", "Power", "Stamina", "Mana");
//
//		radarModel.addDataset(Dataset.Builder.init().label("Goku").backgroundColor("#ffe900")
//				.data(Arrays.asList(4000, 800, 5000, 2000, 3200)).build());
//
//		radarModel.addDataset(Dataset.Builder.init().label("Vegeta").backgroundColor("#d400ffcc")
//				.data(Arrays.asList(3800, 1800, 3000, 1500, 500)).build());
//
//	}
//
//	private void initMixedModel() {
//		Dataset<Double> chartDataset1 = new Dataset<Double>();
//		chartDataset1.setLabel("Normal Curve");
//		chartDataset1.setType(Chartjs.TYPE_LINE);
//		chartDataset1.setFill(false);
//		IntStream.range(0, 100).mapToDouble(Double::new).forEach(chartDataset1::addData);
//
//		Dataset<Double> chartDataset2 = new Dataset<Double>();
//		chartDataset2.setLabel("Measured Values");
//		chartDataset2.setType(Chartjs.TYPE_SCATTER);
//		chartDataset2.setBackgroundColor("#ff0000");
//		chartDataset2.setFill(false);
//		IntStream.range(0, 20).mapToDouble(e -> Math.random() * 100).forEach(chartDataset2::addData);
//
//		ChartjsData chartData = new ChartjsData();
//		chartData.addDataset(chartDataset1);
//		chartData.addDataset(chartDataset2);
//		chartData.addDataset(getCategoryModel().getDataset());
//		this.mixedModel = chartData;
//	}
//
//	public CategoryChartjsData getCategoryModel() {
//		return categoryModel;
//	}
//
//	public ChartjsData getXyModel() {
//		return xyModel;
//	}
//
//	public void setCategoryModel(CategoryChartjsData categoryModel) {
//		this.categoryModel = categoryModel;
//	}
//
//	public void setXyModel(ChartjsData xyModel) {
//		this.xyModel = xyModel;
//	}
//
//	public ChartjsData getLineModel() {
//		return lineModel;
//	}
//
//	public void setLineModel(ChartjsData lineModel) {
//		this.lineModel = lineModel;
//	}
//
//	public ChartjsData getXyzModel() {
//		return xyzModel;
//	}
//	public void setXyzModel(ChartjsData xyzModel) {
//		this.xyzModel = xyzModel;
//	}
//
//	public ChartjsData getRadarModel() {
//		return radarModel;
//	}
//
//	public void setRadarModel(ChartjsData radarModel) {
//		this.radarModel = radarModel;
//	}
//
//	public ChartjsOptions getXyOptions() {
//		return xyOptions;
//	}
//
//	public void setXyOptions(ChartjsOptions xyOptions) {
//		this.xyOptions = xyOptions;
//	}
//
//	public ChartjsData getMixedModel() {
//		return mixedModel;
//	}
//
//	public void setMixedModel(ChartjsData mixedModel) {
//		this.mixedModel = mixedModel;
//	}
//
//	@Override
//	public void onEvent(Event event) throws Exception {
//		// TODO Auto-generated method stub
//		
//	}
//}
//

	package org.adempiere.webui.dashboard;

import org.adempiere.webui.component.Button;
import org.adempiere.webui.component.Combobox;
import org.adempiere.webui.desktop.IDesktop;
import org.adempiere.webui.session.SessionManager;
import org.adempiere.webui.util.ServerPushTemplate;
import org.compiere.util.CLogger;
import org.compiere.util.DB;
import org.zkoss.zk.ui.Component;
import org.zkoss.zk.ui.event.Event;
import org.zkoss.zk.ui.event.EventListener;
import org.zkoss.zk.ui.event.EventQueue;
import org.zkoss.zk.ui.event.EventQueues;
import org.zkoss.zk.ui.event.Events;
import org.zkoss.zul.Box;
import java.util.List;

import javax.swing.JComboBox;
import javax.swing.JFrame;

import java.awt.Container;
import java.util.ArrayList;
import org.zkoss.zul.Vbox;

public class DAPTest extends DashboardPanel implements EventListener<Event> {


	@SuppressWarnings("unused")
	private static final CLogger logger = CLogger.getCLogger(DAPTest.class);
	
//	private Combobox lstLanguage;

	private Button btnIn,btnInQuty,btnOut,btnOutQuty,btnWarehouse,btnNew;

	private String labelIn,labelInQuty,labelOut,labelOutQuty,labelWarehouse,labelNew;
    private String inName,inQnty,outName,outQnty,warehouse;
    
    private JFrame j;



	public DAPTest() {
		super();
		this.setClass("test-widget");
		this.appendChild(createActivitiesPanel());
//		this.appendChild(comboBox());
//		this.appendChild(newCombo());


	}
	
//	private Component newCombo() {
//		lstLanguage = new Combobox();
//		
//		return null;
//	}

	private Component comboBox() {
		// TODO Auto-generated method stub
		
		j = new JFrame();
		String warehouses[] = {"HQ","Furniture","Grocery","realmeds"};
//		Container con = getContentPane();
//		JComboBox cb = new JComboBox();
		JComboBox cb = new JComboBox(warehouses);
//		cb.addItem("HQ");
//		cb.addItem("Furniture");
		cb.setBounds(50, 50, 90, 20);
		j.add(cb);
		j.setLayout(null);
		j.setVisible(true);
		
		
		return (Component) j;
	}

	private Box createActivitiesPanel() {
		Vbox vbox = new Vbox();

		btnNew = new Button();
		vbox.appendChild(btnNew);
		labelNew = "new";
		btnNew.setTooltiptext(labelNew);
		
		
		btnWarehouse = new Button();
		vbox.appendChild(btnWarehouse);
		labelWarehouse = "Warehouse name";
		btnWarehouse.setLabel(labelWarehouse + " : 0");
		btnWarehouse.setTooltiptext(labelWarehouse);
		
		btnIn = new Button();
		vbox.appendChild(btnIn);
		labelIn = "Rcent In";
		btnIn.setLabel(labelIn + " : 0");
		btnIn.setTooltiptext(labelIn);

		btnInQuty = new Button();
		vbox.appendChild(btnInQuty);
		labelInQuty = "Rcent In Quty";
		btnInQuty.setLabel(labelInQuty + " : 0");
		btnInQuty.setTooltiptext(labelInQuty);
		
		btnOut = new Button();
		vbox.appendChild(btnOut);
		labelOut = "Rcent Out";
		btnOut.setLabel(labelOut + " : 0");
		btnOut.setTooltiptext(labelOut);
		
		btnOutQuty = new Button();
		vbox.appendChild(btnOutQuty);
		labelOutQuty = "Rcent Out Quty";
		btnOutQuty.setLabel(labelOutQuty + " : 0");
		btnOutQuty.setTooltiptext(labelOutQuty);
		return vbox;
	}

	@Override
	public void refresh(ServerPushTemplate template) {
		
		List<String> listIn = new ArrayList<>();
        List<String> ListOut = new ArrayList<>();

        listIn = DB.getSQLValueStringForTest(null,
                "select movementqty, name from adempiere.m_product a join adempiere.m_inoutline b on a.m_product_id=b.m_product_id \n"
                        + "join adempiere.m_inout c on c.m_inout_id=b.m_inout_id where c.m_warehouse_id=50002 and c.movementtype='V+' \n"
                        + "order by movementdate DESC limit 1;\n" + "");
        
        ListOut = DB.getSQLValueStringForTest(null,
                "select movementqty, name from adempiere.m_product a join adempiere.m_inoutline b on a.m_product_id=b.m_product_id \n"
                        + "join adempiere.m_inout c on c.m_inout_id=b.m_inout_id where c.m_warehouse_id=50002 and c.movementtype='C-' \n"
                        + "order by movementdate DESC limit 1;\n" + "");
        
        String inNameData = listIn.get(0);
        String inQntyData = listIn.get(1);
        String outNameData = ListOut.get(0);
        String outQntyData = ListOut.get(1);
//1000000
        inName = inNameData;
        inQnty = inQntyData;
        outName = outNameData;
        outQnty= outQntyData;
        warehouse = "Grocery";
	

		template.executeAsync(this);
	}

	@Override
	public void updateUI() {
		btnIn.setLabel(labelIn + " : " + inName);
		btnInQuty.setLabel(labelInQuty + " : " + inQnty);
		btnOut.setLabel(labelOut + " : " + outName);
		btnOutQuty.setLabel(labelOutQuty + " : " + outQnty);
		btnWarehouse.setLabel(labelWarehouse + " : " + warehouse);
		
//		btnWarehouse.addEventListener(inName, null);
	
//		btnNew.setLabel(labelNew + " : " + noOfNew);

		EventQueue<Event> queue = EventQueues.lookup(IDesktop.ACTIVITIES_EVENT_QUEUE, true);
		Event event = new Event(IDesktop.ON_ACTIVITIES_CHANGED_EVENT, null,
				inName + inQnty + outName + outQnty + warehouse);
		queue.publish(event);
	}

	@Override
	public boolean isPooling() {
		return true;
	}

	public void onEvent(Event event) {
		Component comp = event.getTarget();
		String eventName = event.getName();

		if (eventName.equals(Events.ON_CLICK)) {
			if (comp instanceof Button) {
				Button btn = (Button) comp;

				int menuId = 0;
				try {
					menuId = Integer.valueOf(btn.getName());
				} catch (Exception e) {

				}

				if (menuId > 0)
					SessionManager.getAppDesktop().onMenuSelected(menuId);
			}
		}
			
	}

	@Override
	public boolean isLazy() {
		return true;
	}

//	private static final long serialVersionUID = 1L;
//	
//	private Vlayout layout = new Vlayout();
//	private Div contentArea = new Div();
//	
//	private Checkbox aCheckbox = new Checkbox();
//	private Textbox aTextbox = new Textbox();
//
//	 public DAPTest() {
//		// TODO Auto-generated constructor stub
//	super();
//		
//		this.setHeight("200px");
////		this.setClass("apanel-Box");
//		
//		initLayout();
//		initComponent();
//	}
//
//	private void initComponent() {
//		// TODO Auto-generated method stub
//		aCheckbox.addEventListener(Events.ON_CLICK, this);
//		aCheckbox.setTooltiptext("This is a checkbox");
//		
//		aTextbox.addEventListener(Events.ON_BLUR, this);
//		aTextbox.addEventListener(Events.ON_OK, this);
//		aTextbox.setHflex("1");
//		
//		Label aLabel = new Label("This is a Label");
//		
//		Vbox box = new Vbox();
//		box.setHflex("1");
//		box.setVflex("1");
//		box.setStyle("margin:5px,5px;");
//		box.appendChild(aCheckbox);
//		box.appendChild(aTextbox);
//		box.appendChild(aLabel);
//		contentArea.appendChild(box);
//		
//	}
//
//	private void initLayout() {
//		// TODO Auto-generated method stub
//		
//		layout.setParent(this);
//		layout.setClass("test-layout");
//		layout.setSpacing("0px");
//		layout.setStyle("height: 100%, width: 100%");
//		
//		contentArea.setParent(layout);
//		contentArea.setVflex("1");
//		contentArea.setHflex("1");
//		contentArea.setStyle("margin:5px 5px;overflow: auto;");
//		
//	}
////
//	@Override
//	public void onEvent(Event event) throws Exception {
//		// TODO Auto-generated method stub
//		
//		Component comp = event.getTarget();
//		String eventName = event.getName();
//		
//		System.out.println("chi");
//		
//		if(eventName.equals(Events.ON_CLICK)) {
//			log.warning("----------------------Click");
//		}else if(eventName.equals(Events.ON_BLUR)) {
//			log.warning("-----------------------Blur");
//		}else if(eventName.equals(Events.ON_OK)) {
//			log.warning("--------------------OK");
//		}
//		
//		
//	}

}
