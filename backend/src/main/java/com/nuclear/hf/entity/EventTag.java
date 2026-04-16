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
@Table(name = "event_tag")
public class EventTag {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "event_id", nullable = false)
    private Long eventId;

    @Column(name = "task_id")
    private Long taskId;

    @Column(name = "tag_id", nullable = false)
    private Long tagId;

    @Column(name = "label_basis", columnDefinition = "TEXT")
    private String labelBasis;

    @Column(name = "reviewer", length = 100)
    private String reviewer;

    @Column(name = "review_status", nullable = false, length = 30)
    private String reviewStatus = "pending";

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
