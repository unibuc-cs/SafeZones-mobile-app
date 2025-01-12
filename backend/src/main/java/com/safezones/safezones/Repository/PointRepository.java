package com.safezones.safezones.Repository;

import com.safezones.safezones.Model.Point;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface PointRepository extends CrudRepository<Point, Integer> {
    List<Point> findByUserId(String userId);
}
