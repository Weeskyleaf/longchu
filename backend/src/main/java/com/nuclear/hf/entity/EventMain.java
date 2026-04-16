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
@Table(name = "event_main")
public class EventMain {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "event_code", nullable = false, unique = true, length = 64)
    private String eventCode;

    @Column(name = "event_title", nullable = false, length = 200)
    private String eventTitle;

    @Column(name = "event_type", nullable = false, length = 50)
    private String eventType;

    @Column(name = "main_category", nullable = false, length = 50)
    private String mainCategory;

    @Column(name = "sub_category", length = 50)
    private String subCategory;

    @Column(name = "occur_time", nullable = false)
    private LocalDateTime occurTime;

    @Column(name = "plant_name", length = 100)
    private String plantName;

    @Column(name = "unit_no", nullable = false, length = 20)
    private String unitNo;

    @Column(name = "system_name", length = 100)
    private String systemName;

    @Column(name = "operation_mode", length = 50)
    private String operationMode;

    @Column(name = "consequence_level", length = 50)
    private String consequenceLevel;

    @Column(name = "event_result", length = 200)
    private String eventResult;

    @Column(name = "source_type", nullable = false, length = 50)
    private String sourceType;

    @Column(name = "raw_text", columnDefinition = "TEXT", nullable = false)
    private String rawText;

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
