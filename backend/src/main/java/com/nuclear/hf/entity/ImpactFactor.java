package com.nuclear.hf.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "impact_factor")
public class ImpactFactor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "event_id", nullable = false)
    private Long eventId;

    @Column(name = "task_id")
    private Long taskId;

    @Column(name = "factor_category", nullable = false, length = 50)
    private String factorCategory;

    @Column(name = "factor_name", nullable = false, length = 100)
    private String factorName;

    @Column(name = "factor_level", length = 50)
    private String factorLevel;

    @Column(name = "factor_value", length = 100)
    private String factorValue;

    @Column(name = "assessment_basis", columnDefinition = "TEXT")
    private String assessmentBasis;

    @Column(name = "data_source", length = 50)
    private String dataSource;

    @Column(name = "method_mapping", length = 50)
    private String methodMapping;

    @Column(name = "remark", length = 255)
    private String remark;
}
