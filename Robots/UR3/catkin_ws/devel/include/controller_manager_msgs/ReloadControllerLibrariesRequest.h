// Generated by gencpp from file controller_manager_msgs/ReloadControllerLibrariesRequest.msg
// DO NOT EDIT!


#ifndef CONTROLLER_MANAGER_MSGS_MESSAGE_RELOADCONTROLLERLIBRARIESREQUEST_H
#define CONTROLLER_MANAGER_MSGS_MESSAGE_RELOADCONTROLLERLIBRARIESREQUEST_H


#include <string>
#include <vector>
#include <map>

#include <ros/types.h>
#include <ros/serialization.h>
#include <ros/builtin_message_traits.h>
#include <ros/message_operations.h>


namespace controller_manager_msgs
{
template <class ContainerAllocator>
struct ReloadControllerLibrariesRequest_
{
  typedef ReloadControllerLibrariesRequest_<ContainerAllocator> Type;

  ReloadControllerLibrariesRequest_()
    : force_kill(false)  {
    }
  ReloadControllerLibrariesRequest_(const ContainerAllocator& _alloc)
    : force_kill(false)  {
  (void)_alloc;
    }



   typedef uint8_t _force_kill_type;
  _force_kill_type force_kill;




  typedef boost::shared_ptr< ::controller_manager_msgs::ReloadControllerLibrariesRequest_<ContainerAllocator> > Ptr;
  typedef boost::shared_ptr< ::controller_manager_msgs::ReloadControllerLibrariesRequest_<ContainerAllocator> const> ConstPtr;

}; // struct ReloadControllerLibrariesRequest_

typedef ::controller_manager_msgs::ReloadControllerLibrariesRequest_<std::allocator<void> > ReloadControllerLibrariesRequest;

typedef boost::shared_ptr< ::controller_manager_msgs::ReloadControllerLibrariesRequest > ReloadControllerLibrariesRequestPtr;
typedef boost::shared_ptr< ::controller_manager_msgs::ReloadControllerLibrariesRequest const> ReloadControllerLibrariesRequestConstPtr;

// constants requiring out of line definition



template<typename ContainerAllocator>
std::ostream& operator<<(std::ostream& s, const ::controller_manager_msgs::ReloadControllerLibrariesRequest_<ContainerAllocator> & v)
{
ros::message_operations::Printer< ::controller_manager_msgs::ReloadControllerLibrariesRequest_<ContainerAllocator> >::stream(s, "", v);
return s;
}

} // namespace controller_manager_msgs

namespace ros
{
namespace message_traits
{



// BOOLTRAITS {'IsFixedSize': True, 'IsMessage': True, 'HasHeader': False}
// {'controller_manager_msgs': ['/home/wonchul/catkin_ws/src/ros_control-kinetic-devel/controller_manager_msgs/msg'], 'std_msgs': ['/opt/ros/kinetic/share/std_msgs/cmake/../msg']}

// !!!!!!!!!!! ['__class__', '__delattr__', '__dict__', '__doc__', '__eq__', '__format__', '__getattribute__', '__hash__', '__init__', '__module__', '__ne__', '__new__', '__reduce__', '__reduce_ex__', '__repr__', '__setattr__', '__sizeof__', '__str__', '__subclasshook__', '__weakref__', '_parsed_fields', 'constants', 'fields', 'full_name', 'has_header', 'header_present', 'names', 'package', 'parsed_fields', 'short_name', 'text', 'types']




template <class ContainerAllocator>
struct IsFixedSize< ::controller_manager_msgs::ReloadControllerLibrariesRequest_<ContainerAllocator> >
  : TrueType
  { };

template <class ContainerAllocator>
struct IsFixedSize< ::controller_manager_msgs::ReloadControllerLibrariesRequest_<ContainerAllocator> const>
  : TrueType
  { };

template <class ContainerAllocator>
struct IsMessage< ::controller_manager_msgs::ReloadControllerLibrariesRequest_<ContainerAllocator> >
  : TrueType
  { };

template <class ContainerAllocator>
struct IsMessage< ::controller_manager_msgs::ReloadControllerLibrariesRequest_<ContainerAllocator> const>
  : TrueType
  { };

template <class ContainerAllocator>
struct HasHeader< ::controller_manager_msgs::ReloadControllerLibrariesRequest_<ContainerAllocator> >
  : FalseType
  { };

template <class ContainerAllocator>
struct HasHeader< ::controller_manager_msgs::ReloadControllerLibrariesRequest_<ContainerAllocator> const>
  : FalseType
  { };


template<class ContainerAllocator>
struct MD5Sum< ::controller_manager_msgs::ReloadControllerLibrariesRequest_<ContainerAllocator> >
{
  static const char* value()
  {
    return "18442b59be9479097f11c543bddbac62";
  }

  static const char* value(const ::controller_manager_msgs::ReloadControllerLibrariesRequest_<ContainerAllocator>&) { return value(); }
  static const uint64_t static_value1 = 0x18442b59be947909ULL;
  static const uint64_t static_value2 = 0x7f11c543bddbac62ULL;
};

template<class ContainerAllocator>
struct DataType< ::controller_manager_msgs::ReloadControllerLibrariesRequest_<ContainerAllocator> >
{
  static const char* value()
  {
    return "controller_manager_msgs/ReloadControllerLibrariesRequest";
  }

  static const char* value(const ::controller_manager_msgs::ReloadControllerLibrariesRequest_<ContainerAllocator>&) { return value(); }
};

template<class ContainerAllocator>
struct Definition< ::controller_manager_msgs::ReloadControllerLibrariesRequest_<ContainerAllocator> >
{
  static const char* value()
  {
    return "\n\
\n\
\n\
\n\
\n\
\n\
\n\
\n\
bool force_kill\n\
";
  }

  static const char* value(const ::controller_manager_msgs::ReloadControllerLibrariesRequest_<ContainerAllocator>&) { return value(); }
};

} // namespace message_traits
} // namespace ros

namespace ros
{
namespace serialization
{

  template<class ContainerAllocator> struct Serializer< ::controller_manager_msgs::ReloadControllerLibrariesRequest_<ContainerAllocator> >
  {
    template<typename Stream, typename T> inline static void allInOne(Stream& stream, T m)
    {
      stream.next(m.force_kill);
    }

    ROS_DECLARE_ALLINONE_SERIALIZER
  }; // struct ReloadControllerLibrariesRequest_

} // namespace serialization
} // namespace ros

namespace ros
{
namespace message_operations
{

template<class ContainerAllocator>
struct Printer< ::controller_manager_msgs::ReloadControllerLibrariesRequest_<ContainerAllocator> >
{
  template<typename Stream> static void stream(Stream& s, const std::string& indent, const ::controller_manager_msgs::ReloadControllerLibrariesRequest_<ContainerAllocator>& v)
  {
    s << indent << "force_kill: ";
    Printer<uint8_t>::stream(s, indent + "  ", v.force_kill);
  }
};

} // namespace message_operations
} // namespace ros

#endif // CONTROLLER_MANAGER_MSGS_MESSAGE_RELOADCONTROLLERLIBRARIESREQUEST_H
