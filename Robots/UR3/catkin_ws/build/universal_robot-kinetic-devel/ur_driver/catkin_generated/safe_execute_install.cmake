execute_process(COMMAND "/home/wonchul/catkin_ws/build/universal_robot-kinetic-devel/ur_driver/catkin_generated/python_distutils_install.sh" RESULT_VARIABLE res)

if(NOT res EQUAL 0)
  message(FATAL_ERROR "execute_process(/home/wonchul/catkin_ws/build/universal_robot-kinetic-devel/ur_driver/catkin_generated/python_distutils_install.sh) returned error code ")
endif()
