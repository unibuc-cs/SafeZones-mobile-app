package com.safezones.safezones;

import com.safezones.safezones.users.User;
import org.springframework.data.repository.CrudRepository;


public interface UserRepository extends CrudRepository<User, String> {

}   