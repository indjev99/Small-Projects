#ifndef ROUTER_H_
#define ROUTER_H_

#include <map>
#include <string>

#include <omnetpp.h>
using namespace omnetpp;

#include "UpdatePacket_m.h"
#include "MessagePacket_m.h"

#define INFINITE_ROUTE_COST DBL_MAX
#define UPDATE_PACKET  1
#define MESSAGE_PACKET 2

class Route {
 public:
  std::string dest;
  std::string nextHop;
  double cost;
};

class Router : public cSimpleModule {
 protected:
   virtual void initialize();
   virtual void finish();

   // the message dispatcher function called by omnet whenever a message
   // arrives for this router
   virtual void handleMessage(cMessage *msg);

 private:
  double INF;

  // utility function
  void printRoutingTable();
  // sends the routing update for destination dest to all neighbours
  void sendCost(std::string dest);
  // returns the gate belonging to neighbour n
  cGate* findGateForNeighbour(std::string n);
  // forwards a message
  void forwardMessage(std::string dest, std::string data);

  // activity functions are called from within handleMessage upon receipt of
  // a message
  void sendRoutingUpdatesActivity();
  void updateRoutesActivity(UpdatePacket* p);
  void sendMessageToOtherRouterActivity(std::string dest);
  void checkAliveActivity();

  // a map from the router name ("A", "B", ...) to its correspoding Route
  // object
  std::map<std::string, Route> routes;

  // a map from the router name ("A", "B", ...) to the most recent timestamp 
  // when a message from that neighbouring router was last received
  std::map<std::string, simtime_t> lastSeen;

  // activity messages
  cMessage* periodic_update_activity;
  cMessage* message_sending_activity;
  cMessage* check_alive_activity;

};

#endif  // ROUTER_H_
