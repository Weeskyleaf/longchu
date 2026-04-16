package com.nuclear.hf.repository;

import com.nuclear.hf.entity.TagDict;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TagDictRepository extends JpaRepository<TagDict, Long> {

    List<TagDict> findByTagType(String tagType);

    List<TagDict> findByIsActive(Integer isActive);
}
