//
//  StatisticsViewController.swift
//  Journal
//
//  Created by Edward Huang on 2/25/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {

    @IBOutlet weak var chart: ChartView!
    @IBOutlet weak var timeFrame: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateChart()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBActions
    
    @IBAction func timeFrameChanged(_ sender: UISegmentedControl) {
        updateChart()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Private Functions
    private func updateChart() {
        let calendarComponent: Calendar.Component
        switch timeFrame.selectedSegmentIndex {
        case 0:
            calendarComponent = .weekOfMonth
        case 1:
            calendarComponent = .month
        case 2:
            calendarComponent = .quarter
        case 3:
            calendarComponent = .year
        default:
            calendarComponent = .calendar
        }
        
        let chartData: ChartData = EntryHistorian.getChartData(for: calendarComponent)
        
        // Bottom X labels
        var bottomXLabels: [String] = []
        let startDate = chartData.startDate.date!
        let dataTimeFrame = chartData.dataCalendarComponent
        let calendar = Calendar.current
        var currentDate: Date
        for i in 0..<chartData.size {
            currentDate = calendar.date(byAdding: dataTimeFrame, value: i, to: startDate)!
            let component = calendar.component(dataTimeFrame, from: currentDate)
            bottomXLabels.append("\(component)")
        }
        
        // Top X Labels
        var topXLabels: [String] = []
        let higherComponent: Calendar.Component = dataTimeFrame.higherComponent
        let component = calendar.component(higherComponent, from: startDate)
        topXLabels.append("\(component)")
        
        chart.configure(yValues: chartData.data, bottomXLabels: bottomXLabels, topXLabels: topXLabels)
    }

}
