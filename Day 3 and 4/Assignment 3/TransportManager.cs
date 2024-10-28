namespace Assignments.AssignmentThree
{
    //Create a TransportManager class to manage a list of transport schedules.
    internal class TransportManager
    {
        //LINQ Operations:
        private static readonly List<TransportSchedule> TransportSchedules = new();
        private List<TransportSchedule> _schedules = TransportSchedules;

        public void AddSchedule(TransportSchedule schedule)
        {
            _schedules.Add(schedule);
        }
        //Search: Find schedules by transport type, route, or time.
        public IEnumerable<TransportSchedule> SearchSchedules(string transportType, string route, DateTime? departureTime)
        {
            return _schedules.Where(s =>
                (s.TransportType.Equals(transportType)) &&
                (s.Route.Equals(route)) &&
                (!departureTime.HasValue || s.DepartureTime.Date == departureTime.Value.Date));
        }
        //Group By: Group schedules by transport type (bus or flight).
        public IEnumerable<IGrouping<string, TransportSchedule>> GroupSchedulesByTransportType()
        {
            return _schedules.GroupBy(s => s.TransportType);
        }

        //Order By: Order schedules by departure time, price, or seats available.
        public IEnumerable<TransportSchedule> OrderSchedules(string orderBy)
        {
            if (orderBy.ToLower() == "departuretime")
            {
                return _schedules.OrderBy(s => s.DepartureTime);
            }
            else if (orderBy.ToLower() == "price")
            {
                return _schedules.OrderBy(s => s.Price);
            }
            else if (orderBy.ToLower() == "seatsavailable")
            {
                return _schedules.OrderBy(s => s.SeatsAvailable);
            }
            else
            {
                return _schedules;
            }
        }

        //Filter: Filter schedules based on availability of seats or routes within a time range.
        public IEnumerable<TransportSchedule> FilterSchedules(DateTime startTime, DateTime endTime)
        {
            return _schedules.Where(s => s.DepartureTime >= startTime && s.DepartureTime <= endTime);
        }

        //Aggregate: Calculate the total number of available seats and the average price of transport.
        public (int totalSeats, decimal averagePrice) AggregateSeatsAndPrice()
        {
            int totalSeats = _schedules.Sum(s => s.SeatsAvailable);
            decimal averagePrice = _schedules.Average(s => s.Price);
            return (totalSeats, averagePrice);
        }

        //Select: Project a list of routes and their departure times.
        public IEnumerable<(string Route, DateTime DepartureTime)> GetRoutesAndDepartureTimes()
        {
            return _schedules.Select(s => (s.Route, s.DepartureTime));
        }
    }
}
