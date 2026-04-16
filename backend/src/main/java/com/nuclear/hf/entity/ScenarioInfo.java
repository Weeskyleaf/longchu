package com.nuclear.hf.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "scenario_info")
public class ScenarioInfo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "event_id", nullable = false)
    private Long eventId;

    @Column(name = "task_id")
    private Long taskId;

    @Column(name = "scenario_name", nullable = false, length = 100)
    private String scenarioName;

    @Column(name = "system_state", nullable = false, length = 100)
    private String systemState;

    @Column(name = "environmental_condition", columnDefinition = "TEXT")
    private String environmentalCondition;

    @Column(name = "interface_state", columnDefinition = "TEXT")
    private String interfaceState;

    @Column(name = "procedure_state", length = 100)
    private String procedureState;

    @Column(name = "time_pressure_desc", length = 100)
    private String timePressureDesc;

    @Column(name = "remark", length = 255)
    private String remark;
}
