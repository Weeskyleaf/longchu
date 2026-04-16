package com.nuclear.hf.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "tag_dict")
public class TagDict {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "tag_type", nullable = false, length = 30)
    private String tagType;

    @Column(name = "tag_code", nullable = false, unique = true, length = 64)
    private String tagCode;

    @Column(name = "tag_name", nullable = false, length = 50)
    private String tagName;

    @Column(name = "tag_value", nullable = false, length = 100)
    private String tagValue;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "standard_ref", length = 255)
    private String standardRef;

    @Column(name = "is_active", nullable = false)
    private Integer isActive = 1;
}
