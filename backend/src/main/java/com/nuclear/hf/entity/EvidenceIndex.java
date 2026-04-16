package com.nuclear.hf.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "evidence_index")
public class EvidenceIndex {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "case_id", nullable = false)
    private Long caseId;

    @Column(name = "case_task_id")
    private Long caseTaskId;

    @Column(name = "trace_step", nullable = false, length = 30)
    private String traceStep;

    @Column(name = "source_table", nullable = false, length = 50)
    private String sourceTable;

    @Column(name = "source_pk", nullable = false)
    private Long sourcePk;

    @Column(name = "evidence_excerpt", columnDefinition = "TEXT")
    private String evidenceExcerpt;

    @Column(name = "attachment_uri", length = 255)
    private String attachmentUri;

    @Column(name = "recorder", length = 100)
    private String recorder;
}
