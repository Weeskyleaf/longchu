package com.nuclear.hf.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "analysis_case")
public class AnalysisCase {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "case_code", nullable = false, unique = true, length = 64)
    private String caseCode;

    @Column(name = "method_code", nullable = false, length = 32)
    private String methodCode = "SPAR-H";

    @Column(name = "source_event_id")
    private Long sourceEventId;

    @Column(name = "source_task_id")
    private Long sourceTaskId;

    @Column(name = "source_scene_id")
    private Long sourceSceneId;

    @Column(name = "analysis_path", nullable = false, length = 20)
    private String analysisPath;

    @Column(name = "case_name", nullable = false, length = 200)
    private String caseName;

    @Column(name = "analyst", length = 100)
    private String analyst;

    @Column(name = "review_status", nullable = false, length = 20)
    private String reviewStatus = "draft";

    @Column(name = "model_version", length = 32)
    private String modelVersion;

    @Column(name = "summary", columnDefinition = "TEXT")
    private String summary;

    @Column(name = "ext_json", columnDefinition = "TEXT")
    private String extJson;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
