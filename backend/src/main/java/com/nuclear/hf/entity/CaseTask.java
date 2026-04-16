package com.nuclear.hf.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "case_task")
public class CaseTask {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "case_id", nullable = false)
    private Long caseId;

    @Column(name = "task_type", nullable = false, length = 20)
    private String taskType;

    @Column(name = "nominal_hep", nullable = false, precision = 16, scale = 10)
    private BigDecimal nominalHep;

    @Column(name = "composite_psf", precision = 16, scale = 10)
    private BigDecimal compositePsf;

    @Column(name = "raw_hep", precision = 16, scale = 10)
    private BigDecimal rawHep;

    @Column(name = "adjusted_hep", precision = 16, scale = 10)
    private BigDecimal adjustedHep;

    @Column(name = "negative_count", nullable = false)
    private Integer negativeCount = 0;

    @Column(name = "final_hep", precision = 16, scale = 10)
    private BigDecimal finalHep;

    @Column(name = "calc_note", columnDefinition = "TEXT")
    private String calcNote;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
