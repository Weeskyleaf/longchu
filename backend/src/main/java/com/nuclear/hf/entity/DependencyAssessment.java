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
@Table(name = "dependency_assessment")
public class DependencyAssessment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "case_id", nullable = false)
    private Long caseId;

    @Column(name = "from_task_id", nullable = false)
    private Long fromTaskId;

    @Column(name = "to_task_id", nullable = false)
    private Long toTaskId;

    @Column(name = "dependency_level", nullable = false, length = 20)
    private String dependencyLevel;

    @Column(name = "same_crew_flag", nullable = false)
    private Integer sameCrewFlag = 0;

    @Column(name = "close_in_time_flag", nullable = false)
    private Integer closeInTimeFlag = 0;

    @Column(name = "same_location_flag", nullable = false)
    private Integer sameLocationFlag = 0;

    @Column(name = "same_cues_flag", nullable = false)
    private Integer sameCuesFlag = 0;

    @Column(name = "correction_value", precision = 12, scale = 6)
    private BigDecimal correctionValue;

    @Column(name = "basis_text", columnDefinition = "TEXT")
    private String basisText;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
