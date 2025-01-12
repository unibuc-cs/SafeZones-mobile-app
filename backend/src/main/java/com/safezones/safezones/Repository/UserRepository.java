package com.safezones.safezones.Repository;

import com.safezones.safezones.Model.User;
import org.springframework.data.repository.CrudRepository;


public interface UserRepository extends CrudRepository<User, String> {

}   