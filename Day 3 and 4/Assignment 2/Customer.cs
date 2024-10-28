namespace Assignments.AssignmentTwo
{
    internal class Customer
    {
        public string Name { get; set; }
        public string Email { get; set; }
        public string PhoneNumber { get; set; }
        public DateTime DateOfBirth { get; set; }

        public override string ToString()
        {
            return $"Name: {Name}\t Email: {Email}\t Phone Number: {PhoneNumber}\t DateOfBirth: {DateOfBirth}";
        }
    }
}
