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
@Table(name = "evidence_chain")
public class EvidenceChain {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "event_id", nullable = false)
    private Long eventId;

    @Column(name = "evidence_type", nullable = false, length = 50)
    private String evidenceType;

    @Column(name = "doc_code", length = 64)
    private String docCode;

    @Column(name = "doc_title", length = 255)
    private String docTitle;

    @Column(name = "source_ref", length = 255)
    private String sourceRef;

    @Column(name = "page_tag", length = 50)
    private String pageTag;

    @Column(name = "quote_note", columnDefinition = "TEXT")
    private String quoteNote;

    @Column(name = "version_no", length = 30)
    private String versionNo;

    @Column(name = "operator_name", length = 100)
    private String operatorName;

    @Column(name = "operate_time", nullable = false)
    private LocalDateTime operateTime;

    @Column(name = "audit_comment", columnDefinition = "TEXT")
    private String auditComment;

    @PrePersist
    protected void onCreate() {
        if (operateTime == null) {
            operateTime = LocalDateTime.now();
        }
    }
}
