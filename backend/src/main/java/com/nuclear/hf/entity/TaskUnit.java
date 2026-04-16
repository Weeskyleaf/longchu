package com.nuclear.hf.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "task_unit")
public class TaskUnit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "event_id", nullable = false)
    private Long eventId;

    @Column(name = "task_code", nullable = false, unique = true, length = 64)
    private String taskCode;

    @Column(name = "task_name", nullable = false, length = 200)
    private String taskName;

    @Column(name = "task_type", nullable = false, length = 30)
    private String taskType;

    @Column(name = "task_stage", nullable = false, length = 30)
    private String taskStage;

    @Column(name = "operation_object", length = 100)
    private String operationObject;

    @Column(name = "procedure_ref", length = 100)
    private String procedureRef;

    @Column(name = "available_time", precision = 10, scale = 2)
    private BigDecimal availableTime;

    @Column(name = "start_condition", columnDefinition = "TEXT")
    private String startCondition;

    @Column(name = "end_condition", columnDefinition = "TEXT")
    private String endCondition;

    @Column(name = "task_desc", columnDefinition = "TEXT")
    private String taskDesc;
}
