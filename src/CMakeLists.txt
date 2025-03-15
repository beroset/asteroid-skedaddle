add_executable(${CMAKE_PROJECT_NAME} main.cpp resources.qrc Voice.cpp FileHelper.cpp)

target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE
	AsteroidApp
        espeak)

target_compile_features(${CMAKE_PROJECT_NAME} PUBLIC cxx_std_20)

install(TARGETS ${CMAKE_PROJECT_NAME}
	DESTINATION ${CMAKE_INSTALL_BINDIR})
