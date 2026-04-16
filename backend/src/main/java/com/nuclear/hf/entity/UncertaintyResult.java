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
@Table(name = "uncertainty_result")
public class UncertaintyResult {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "case_task_id", nullable = false)
    private Long caseTaskId;

    @Column(name = "dist_type", nullable = false, length = 20)
    private String distType = "Beta";

    @Column(name = "alpha_param", precision = 18, scale = 8)
    private BigDecimal alphaParam;

    @Column(name = "beta_param", precision = 18, scale = 8)
    private BigDecimal betaParam;

    @Column(name = "error_factor", precision = 12, scale = 6)
    private BigDecimal errorFactor;

    @Column(name = "mean_hep", precision = 16, scale = 10)
    private BigDecimal meanHep;

    @Column(name = "median_hep", precision = 16, scale = 10)
    private BigDecimal medianHep;

    @Column(name = "p05", precision = 16, scale = 10)
    private BigDecimal p05;

    @Column(name = "p50", precision = 16, scale = 10)
    private BigDecimal p50;

    @Column(name = "p95", precision = 16, scale = 10)
    private BigDecimal p95;

    @Column(name = "param_json", columnDefinition = "TEXT")
    private String paramJson;

    @Column(name = "calc_note", columnDefinition = "TEXT")
    private String calcNote;
}
